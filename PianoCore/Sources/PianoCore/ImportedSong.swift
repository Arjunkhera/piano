import Foundation

/// A song that came in from a file: a MIDI file, a MusicXML file or a
/// compressed MusicXML file (.mxl). D2 makes it, and D3 makes levels from its
/// notes.
public struct ImportedSong: Equatable, Codable, Sendable {
    public var title: String
    /// The first tempo in the file. 120 when the file names none.
    public var beatsPerMinute: Double
    /// Beats in one bar, in quarter notes. 4 for 4/4, 3 for 3/4, 3 for 6/8.
    public var beatsPerBar: Double
    /// Every note, sorted by start and then by key. A beat is a quarter note.
    public var notes: [Note]

    public init(title: String, beatsPerMinute: Double = 120, beatsPerBar: Double = 4, notes: [Note]) {
        self.title = title
        self.beatsPerMinute = beatsPerMinute
        self.beatsPerBar = beatsPerBar
        self.notes = notes
    }
}

public enum SongImportError: Error, Equatable, CustomStringConvertible {
    /// The bytes are not a MIDI file, a MusicXML file or an .mxl file.
    case unknownFormat
    /// The file is of a known kind, but it is broken. The text says where.
    case damaged(String)
    /// The file is valid, but this reader does not support it. The text says why.
    case unsupported(String)
    /// The file holds no piano notes.
    case noNotes

    public var description: String {
        switch self {
        case .unknownFormat: return "This is not a MIDI, MusicXML or .mxl file."
        case .damaged(let why): return "The file is damaged: \(why)."
        case .unsupported(let why): return "This file is not supported: \(why)."
        case .noNotes: return "The file holds no piano notes."
        }
    }
}

/// Reads a song file into notes. It picks the reader from the first bytes,
/// not from the file name.
public enum SongImporter {
    public enum Format: Equatable, Sendable {
        case midi
        case musicXML
        case compressedMusicXML
    }

    public static func format(of data: Data) -> Format? {
        let head = [UInt8](data.prefix(512))
        if head.starts(with: Array("MThd".utf8)) { return .midi }
        if head.starts(with: [0x50, 0x4B, 0x03, 0x04]) { return .compressedMusicXML }
        let text = String(decoding: head, as: UTF8.self)
        if text.contains("<score-partwise") || text.contains("<score-timewise") || text.contains("<?xml") {
            return .musicXML
        }
        return nil
    }

    /// Reads `data`. `name` is the file name without its extension. It is the
    /// title when the file names no title.
    public static func read(_ data: Data, name: String) throws -> ImportedSong {
        var song: ImportedSong
        switch format(of: data) {
        case .midi: song = try MIDIFileReader.read(data)
        case .musicXML: song = try MusicXMLReader.read(data)
        case .compressedMusicXML: song = try MusicXMLReader.read(MXLArchive.score(in: data))
        case nil: throw SongImportError.unknownFormat
        }
        if song.notes.isEmpty { throw SongImportError.noNotes }
        if song.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { song.title = name }
        return song
    }
}

extension Note {
    /// The hand for a note when the file does not say: keys below middle C
    /// go to the left hand.
    static func handBySplit(_ key: UInt8) -> Hand {
        key < 60 ? .left : .right
    }
}

extension Array where Element == Note {
    func sortedForSong() -> [Note] {
        sorted { ($0.start, $0.key) < ($1.start, $1.key) }
    }
}
