import Foundation

/// The command line of piano-listen, read into a value. It holds no Mac-only
/// code, so its tests run anywhere.
public struct ListenOptions: Equatable {
    public enum Command: Equatable {
        /// Record what the Mac plays, then write the notes.
        case record(name: String)
        /// Write the notes of an audio file that you own.
        case transcribe(audio: String, name: String)
        /// List the apps that `--app` can name.
        case apps
        /// Say whether Transkun is installed, and where songs go.
        case check
        case help
    }

    public var command: Command
    /// Stop after this many seconds. Nil: stop when you press Return.
    public var seconds: Double?
    /// Record only the apps whose name holds this text.
    public var app: String?
    /// The folder for the MIDI files. Nil: ~/Music/Piano Songs.
    public var outFolder: String?
    /// Keep the WAV recording after Transkun reads it.
    public var keepAudio = false
    /// The torch device for Transkun: cpu or mps.
    public var device = "cpu"

    public init(command: Command) {
        self.command = command
    }

    public struct Problem: Error, Equatable, CustomStringConvertible {
        public var description: String
    }

    public static let usage = """
    piano-listen: record a song the Mac plays and write its notes as a MIDI file.

      piano-listen record "<song name>" [--seconds N] [--app <name>] [--out <folder>] [--keep-audio] [--device cpu|mps]
          Records the sound of the Mac. Play the song, then press Return.
          Transkun writes "<song name>.mid" in ~/Music/Piano Songs.
      piano-listen transcribe <audio file> ["<song name>"] [--out <folder>] [--device cpu|mps]
          Writes the notes of an audio file that you own.
      piano-listen apps     Lists the app names that --app can take.
      piano-listen check    Says whether Transkun is installed.

    A solo piano recording gives the best notes. A full band gives poor notes.
    """

    public static func parse(_ arguments: [String]) throws -> ListenOptions {
        var words: [String] = []
        var flags: [String: String] = [:]
        var keepAudio = false
        var index = 0
        let valueFlags: Set<String> = ["--seconds", "--app", "--out", "--device"]
        while index < arguments.count {
            let word = arguments[index]
            if word == "--keep-audio" {
                keepAudio = true
            } else if word == "-h" || word == "--help" {
                return ListenOptions(command: .help)
            } else if valueFlags.contains(word) {
                guard index + 1 < arguments.count else { throw Problem(description: "\(word) needs a value.") }
                flags[word] = arguments[index + 1]
                index += 1
            } else if word.hasPrefix("--") {
                throw Problem(description: "Unknown option: \(word).")
            } else {
                words.append(word)
            }
            index += 1
        }

        var options: ListenOptions
        switch words.first {
        case nil, "help":
            options = ListenOptions(command: .help)
        case "apps":
            options = ListenOptions(command: .apps)
        case "check":
            options = ListenOptions(command: .check)
        case "record":
            guard words.count == 2 else { throw Problem(description: "Give one song name: piano-listen record \"Let It Be\".") }
            options = ListenOptions(command: .record(name: try fileName(words[1])))
        case "transcribe":
            guard words.count == 2 || words.count == 3 else {
                throw Problem(description: "Give an audio file, and a song name if you want one.")
            }
            let audio = words[1]
            let fallback = URL(fileURLWithPath: audio).deletingPathExtension().lastPathComponent
            options = ListenOptions(command: .transcribe(audio: audio, name: try fileName(words.count == 3 ? words[2] : fallback)))
        case let other?:
            throw Problem(description: "Unknown command: \(other).")
        }

        if let seconds = flags["--seconds"] {
            guard let value = Double(seconds), value > 0, value <= 3600 else {
                throw Problem(description: "--seconds takes a number from 1 to 3600.")
            }
            options.seconds = value
        }
        options.app = flags["--app"]
        options.outFolder = flags["--out"]
        options.keepAudio = keepAudio
        if let device = flags["--device"] {
            guard device == "cpu" || device == "mps" else { throw Problem(description: "--device takes cpu or mps.") }
            options.device = device
        }
        return options
    }

    /// A song name made safe for a file name: no slash, no colon, no leading dot.
    public static func fileName(_ name: String) throws -> String {
        var safe = name
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: ":", with: "-")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        while safe.hasPrefix(".") { safe.removeFirst() }
        guard !safe.isEmpty else { throw Problem(description: "The song name is empty.") }
        return String(safe.prefix(100))
    }
}
