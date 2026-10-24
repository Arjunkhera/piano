import Foundation
import ListenOptions
import PianoCore

@main
struct ListenCommand {
    static func main() async {
        do {
            let options = try ListenOptions.parse(Array(CommandLine.arguments.dropFirst()))
            try await run(options)
        } catch let problem as ListenOptions.Problem {
            printError(problem.description)
            printError("Run `piano-listen help` for the commands.")
            exit(2)
        } catch {
            printError("\(error)")
            exit(1)
        }
    }

    static func run(_ options: ListenOptions) async throws {
        switch options.command {
        case .help:
            print(ListenOptions.usage)
        case .apps:
            for name in try await SystemAudioRecorder.appNames() { print(name) }
        case .check:
            if let command = Transcriber.find() {
                print("Transkun: \(command.path)")
            } else {
                print("Transkun: not installed. Run MacHelper/install.sh.")
            }
            print("Songs go to: \(outFolder(options).path)")
        case .record(let name):
            try await record(name: name, options: options)
        case .transcribe(let audio, let name):
            let folder = try makeOutFolder(options)
            guard let command = Transcriber.find() else { throw Transcriber.Failure.notInstalled }
            try transcribe(
                audio: URL(fileURLWithPath: audio),
                name: name,
                folder: folder,
                transcriber: Transcriber(command: command, device: options.device)
            )
        }
    }

    static func record(name: String, options: ListenOptions) async throws {
        let folder = try makeOutFolder(options)
        let command = Transcriber.find()
        if command == nil {
            print("Transkun is not installed, so this run only records. Run MacHelper/install.sh, then:")
            print("  piano-listen transcribe \"\(folder.appendingPathComponent(name).path).wav\"")
        }
        let audio = folder.appendingPathComponent(name + ".wav")
        let recorder = SystemAudioRecorder(url: audio)
        try await recorder.start(app: options.app)

        let source = options.app.map { "the sound of \($0)" } ?? "the sound of this Mac"
        if let seconds = options.seconds {
            print("Recording \(source) for \(clock(seconds)). Start the song now.")
        } else {
            print("Recording \(source). Start the song now, and press Return when it ends.")
        }
        let meter = Task {
            var warned = false
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                let (seconds, peak) = recorder.progress
                let bars = String(repeating: "|", count: min(20, Int(peak * 20)))
                print("\r  \(clock(seconds))  \(bars)", terminator: "")
                fflush(stdout)
                if !warned, seconds > 5, peak < 0.0001 {
                    print("\n  No sound yet. Is the song playing, and the volume up?")
                    warned = true
                }
            }
        }
        if let seconds = options.seconds {
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
        } else {
            await waitForReturn()
        }
        meter.cancel()
        let length = try await recorder.stop()
        print("\nRecorded \(clock(length)).")

        guard let command else {
            print("The recording is at \(audio.path).")
            return
        }
        try transcribe(
            audio: audio,
            name: name,
            folder: folder,
            transcriber: Transcriber(command: command, device: options.device)
        )
        if options.keepAudio {
            print("The recording stays at \(audio.path).")
        } else {
            try? FileManager.default.removeItem(at: audio)
        }
    }

    static func transcribe(audio: URL, name: String, folder: URL, transcriber: Transcriber) throws {
        let midi = folder.appendingPathComponent(name + ".mid")
        print("Writing the notes with Transkun. This takes a few minutes for a 4-minute song.")
        try transcriber.run(audio: audio, midi: midi)
        let song = try SongImporter.read(Data(contentsOf: midi), name: name)
        let right = song.notes.filter { $0.hand == .right }.count
        let beats = song.notes.map { $0.start + $0.length }.max() ?? 0
        print("""
        Done: \(midi.path)
          \(song.notes.count) notes (\(right) right hand, \(song.notes.count - right) left hand), about \(Int(beats.rounded())) beats.
        Send the file to your iPad (AirDrop or iCloud Drive), then tap Import song in the Piano app.
        """)
    }

    static func outFolder(_ options: ListenOptions) -> URL {
        if let custom = options.outFolder {
            return URL(fileURLWithPath: (custom as NSString).expandingTildeInPath)
        }
        return FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Music/Piano Songs")
    }

    static func makeOutFolder(_ options: ListenOptions) throws -> URL {
        let folder = outFolder(options)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    }

    static func waitForReturn() async {
        await withCheckedContinuation { (done: CheckedContinuation<Void, Never>) in
            DispatchQueue.global().async {
                _ = readLine()
                done.resume()
            }
        }
    }

    static func clock(_ seconds: Double) -> String {
        let whole = Int(seconds.rounded())
        return String(format: "%d:%02d", whole / 60, whole % 60)
    }

    static func printError(_ text: String) {
        FileHandle.standardError.write(Data((text + "\n").utf8))
    }
}
