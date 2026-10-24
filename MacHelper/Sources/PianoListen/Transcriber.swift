import Foundation

/// Runs Transkun, the piano model, on a recording. Transkun is a Python tool;
/// MacHelper/install.sh puts it in its own Python environment.
struct Transcriber {
    enum Failure: Error, CustomStringConvertible {
        case notInstalled
        case failed(Int32)

        var description: String {
            switch self {
            case .notInstalled:
                return "Transkun is not installed. Run MacHelper/install.sh first."
            case .failed(let code):
                return "Transkun stopped with code \(code). Its messages are above."
            }
        }
    }

    /// Where install.sh puts Transkun.
    static let defaultPath = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Library/Application Support/PianoListen/venv/bin/transkun")

    /// The Transkun command: $PIANO_TRANSKUN, else the install.sh copy, else
    /// `transkun` on the PATH.
    static func find() -> URL? {
        let fileManager = FileManager.default
        if let custom = ProcessInfo.processInfo.environment["PIANO_TRANSKUN"],
           fileManager.isExecutableFile(atPath: custom) {
            return URL(fileURLWithPath: custom)
        }
        if fileManager.isExecutableFile(atPath: defaultPath.path) {
            return defaultPath
        }
        let path = ProcessInfo.processInfo.environment["PATH"] ?? ""
        for folder in path.split(separator: ":") {
            let candidate = URL(fileURLWithPath: String(folder)).appendingPathComponent("transkun")
            if fileManager.isExecutableFile(atPath: candidate.path) { return candidate }
        }
        return nil
    }

    let command: URL
    /// The torch device: "cpu" (the default and the safe one) or "mps".
    var device = "cpu"

    /// Writes the notes of `audio` to `midi`. Transkun prints its own messages.
    func run(audio: URL, midi: URL) throws {
        let process = Process()
        process.executableURL = command
        process.arguments = [audio.path, midi.path, "--device", device]
        try process.run()
        process.waitUntilExit()
        guard process.terminationStatus == 0 else { throw Failure.failed(process.terminationStatus) }
    }
}
