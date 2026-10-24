import AVFoundation
import CoreMedia
import ScreenCaptureKit

/// Records the sound the Mac plays into a WAV file, with ScreenCaptureKit.
///
/// It records sound only. ScreenCaptureKit needs a display in its filter, so
/// the recorder asks for the smallest video it can and drops every frame.
/// macOS asks once for the Screen Recording permission.
final class SystemAudioRecorder: NSObject, SCStreamOutput, SCStreamDelegate {
    enum Failure: Error, CustomStringConvertible {
        case noDisplay
        case noApp(String)
        case noSound

        var description: String {
            switch self {
            case .noDisplay:
                return "No display found to record from."
            case .noApp(let name):
                return "No open app matches \"\(name)\". Run `piano-listen apps` to see the names."
            case .noSound:
                return "The recording is silent. Check that the song played, and that the Mac volume is not muted."
            }
        }
    }

    let url: URL
    private var stream: SCStream?
    private let queue = DispatchQueue(label: "piano-listen.audio")
    private let lock = NSLock()
    private var file: AVAudioFile?
    private var writeError: Error?
    private var frames: AVAudioFramePosition = 0
    private var sampleRate: Double = 48_000
    private var peak: Float = 0

    init(url: URL) {
        self.url = url
    }

    /// The names of the apps that can be recorded alone, with `--app`.
    static func appNames() async throws -> [String] {
        let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: false)
        return Set(content.applications.map(\.applicationName).filter { !$0.isEmpty }).sorted()
    }

    /// Starts to record. With `app`, it records only the apps whose name or
    /// bundle id holds that text, such as "Safari" or "Chrome".
    func start(app: String?) async throws {
        let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: false)
        guard let display = content.displays.first else { throw Failure.noDisplay }
        let filter: SCContentFilter
        if let app {
            let apps = content.applications.filter {
                $0.applicationName.localizedCaseInsensitiveContains(app)
                    || $0.bundleIdentifier.localizedCaseInsensitiveContains(app)
            }
            guard !apps.isEmpty else { throw Failure.noApp(app) }
            filter = SCContentFilter(display: display, including: apps, exceptingWindows: [])
        } else {
            filter = SCContentFilter(display: display, excludingApplications: [], exceptingWindows: [])
        }

        let configuration = SCStreamConfiguration()
        configuration.capturesAudio = true
        configuration.excludesCurrentProcessAudio = true
        configuration.sampleRate = 44_100
        configuration.channelCount = 2
        configuration.width = 2
        configuration.height = 2
        configuration.minimumFrameInterval = CMTime(value: 1, timescale: 1)
        configuration.showsCursor = false

        let stream = SCStream(filter: filter, configuration: configuration, delegate: self)
        try stream.addStreamOutput(self, type: .audio, sampleHandlerQueue: queue)
        // A screen output too, so ScreenCaptureKit does not log each dropped frame.
        try stream.addStreamOutput(self, type: .screen, sampleHandlerQueue: queue)
        try await stream.startCapture()
        self.stream = stream
    }

    /// Stops and closes the file. Returns the length of the recording in seconds.
    func stop() async throws -> Double {
        if let stream {
            try? await stream.stopCapture()
        }
        stream = nil
        // Let the queue finish the last buffer before the file closes.
        queue.sync {}
        lock.lock()
        defer { lock.unlock() }
        file = nil
        if let writeError { throw writeError }
        guard frames > 0, peak > 0.0001 else { throw Failure.noSound }
        return Double(frames) / sampleRate
    }

    /// Seconds recorded so far, and the loudest sample so far (0 to 1).
    var progress: (seconds: Double, peak: Float) {
        lock.lock()
        defer { lock.unlock() }
        return (Double(frames) / sampleRate, peak)
    }

    func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
        guard type == .audio, sampleBuffer.isValid,
              var description = sampleBuffer.formatDescription?.audioStreamBasicDescription
        else { return }
        do {
            try sampleBuffer.withAudioBufferList { list, _ in
                guard let format = AVAudioFormat(streamDescription: &description),
                      let buffer = AVAudioPCMBuffer(pcmFormat: format, bufferListNoCopy: list.unsafePointer)
                else { return }
                try write(buffer)
            }
        } catch {
            lock.lock()
            writeError = writeError ?? error
            lock.unlock()
        }
    }

    func stream(_ stream: SCStream, didStopWithError error: Error) {
        lock.lock()
        writeError = writeError ?? error
        lock.unlock()
    }

    private func write(_ buffer: AVAudioPCMBuffer) throws {
        lock.lock()
        defer { lock.unlock() }
        if file == nil {
            let format = buffer.format
            // 16-bit PCM: Transkun reads the samples as 16-bit numbers.
            let settings: [String: Any] = [
                AVFormatIDKey: kAudioFormatLinearPCM,
                AVSampleRateKey: format.sampleRate,
                AVNumberOfChannelsKey: format.channelCount,
                AVLinearPCMBitDepthKey: 16,
                AVLinearPCMIsFloatKey: false,
                AVLinearPCMIsBigEndianKey: false,
            ]
            file = try AVAudioFile(
                forWriting: url,
                settings: settings,
                commonFormat: format.commonFormat,
                interleaved: format.isInterleaved
            )
            sampleRate = format.sampleRate
        }
        try file?.write(from: buffer)
        frames += AVAudioFramePosition(buffer.frameLength)
        peak = max(peak, Self.peak(of: buffer))
    }

    private static func peak(of buffer: AVAudioPCMBuffer) -> Float {
        // Count the sound as present when the format is not float.
        guard let channels = buffer.floatChannelData else { return 1 }
        let interleaved = buffer.format.isInterleaved
        let lists = interleaved ? 1 : Int(buffer.format.channelCount)
        let samples = Int(buffer.frameLength) * (interleaved ? Int(buffer.format.channelCount) : 1)
        var loudest: Float = 0
        for list in 0..<lists {
            for index in 0..<samples {
                loudest = max(loudest, abs(channels[list][index]))
            }
        }
        return loudest
    }
}
