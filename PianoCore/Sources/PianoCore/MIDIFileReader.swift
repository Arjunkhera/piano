import Foundation

/// Reads a Standard MIDI File (format 0 or 1) into a song.
///
/// A beat is a quarter note, so a note's start and length come from its ticks
/// divided by the ticks per quarter note. Tempo changes after the first do
/// not move the notes: they change the speed, not the beats.
///
/// The hand of each note comes from the file when it can:
/// 1. A track named "left", "LH", "right" or "RH" sets the hand.
/// 2. Else, when exactly two tracks hold notes, the first is the right hand.
/// 3. Else, keys below middle C go to the left hand.
public enum MIDIFileReader {
    public static func read(_ data: Data) throws -> ImportedSong {
        var reader = ByteReader([UInt8](data))
        guard (try? reader.tag()) == "MThd" else { throw SongImportError.unknownFormat }
        let headerLength = Int(try reader.uint32())
        guard headerLength >= 6 else { throw SongImportError.damaged("the MIDI header is too short") }
        let format = try reader.uint16()
        let trackCount = Int(try reader.uint16())
        let division = try reader.uint16()
        try reader.skip(headerLength - 6)
        guard format <= 1 else { throw SongImportError.unsupported("MIDI format \(format) holds separate songs") }
        guard division & 0x8000 == 0, division > 0 else {
            throw SongImportError.unsupported("the MIDI file counts time in frames, not beats")
        }
        let ticksPerBeat = Double(division)

        var tracks: [Track] = []
        while tracks.count < trackCount, !reader.atEnd {
            let tag = try reader.tag()
            let length = Int(try reader.uint32())
            let body = try reader.bytes(length)
            // Chunks with other tags are allowed, and readers must skip them.
            guard tag == "MTrk" else { continue }
            tracks.append(try Track.read(body))
        }
        guard !tracks.isEmpty else { throw SongImportError.damaged("the MIDI file holds no tracks") }

        let withNotes = tracks.indices.filter { !tracks[$0].notes.isEmpty }
        var notes: [Note] = []
        for index in withNotes {
            let track = tracks[index]
            let named = hand(named: track.name)
            for raw in track.notes {
                let hand: Note.Hand
                if let named {
                    hand = named
                } else if withNotes.count == 2 {
                    hand = index == withNotes[0] ? .right : .left
                } else {
                    hand = Note.handBySplit(raw.key)
                }
                notes.append(Note(
                    key: raw.key,
                    start: Double(raw.startTick) / ticksPerBeat,
                    length: Double(raw.endTick - raw.startTick) / ticksPerBeat,
                    hand: hand
                ))
            }
        }

        let tempo = tracks.lazy.compactMap(\.firstTempo).first
        let meter = tracks.lazy.compactMap(\.firstMeter).first
        return ImportedSong(
            title: tracks[0].name ?? "",
            beatsPerMinute: tempo.map { 60_000_000 / Double($0) } ?? 120,
            beatsPerBar: meter ?? 4,
            notes: notes.sortedForSong()
        )
    }

    static func hand(named name: String?) -> Note.Hand? {
        guard let name else { return nil }
        let words = name.lowercased()
            .split(whereSeparator: { !$0.isLetter })
            .map(String.init)
        if words.contains("left") || words.contains("lh") || words.contains("bass") { return .left }
        if words.contains("right") || words.contains("rh") || words.contains("treble") { return .right }
        return nil
    }

    struct RawNote: Equatable {
        var key: UInt8
        var startTick: Int
        var endTick: Int
    }

    struct Track {
        var name: String?
        var notes: [RawNote] = []
        /// Microseconds per quarter note.
        var firstTempo: UInt32?
        /// Beats in a bar, in quarter notes.
        var firstMeter: Double?

        static func read(_ body: [UInt8]) throws -> Track {
            var track = Track()
            var reader = ByteReader(body)
            var tick = 0
            var status: UInt8?
            // Open notes by channel and key, oldest first.
            var open: [Int: [Int]] = [:]

            func close(channel: UInt8, key: UInt8) {
                let slot = Int(channel) << 8 | Int(key)
                guard var starts = open[slot], !starts.isEmpty else { return }
                let start = starts.removeFirst()
                open[slot] = starts
                if pianoKeys.contains(key) {
                    track.notes.append(RawNote(key: key, startTick: start, endTick: tick))
                }
            }

            while !reader.atEnd {
                tick += Int(try reader.variableLength())
                var byte = try reader.uint8()
                if byte == 0xFF {
                    let type = try reader.uint8()
                    let data = try reader.bytes(Int(try reader.variableLength()))
                    switch type {
                    case 0x03 where track.name == nil:
                        track.name = String(decoding: data, as: UTF8.self)
                    case 0x51 where track.firstTempo == nil && data.count == 3:
                        track.firstTempo = UInt32(data[0]) << 16 | UInt32(data[1]) << 8 | UInt32(data[2])
                    case 0x58 where track.firstMeter == nil && data.count >= 2:
                        let beatType = pow(2, Double(data[1]))
                        track.firstMeter = Double(data[0]) * 4 / beatType
                    case 0x2F:
                        // End of track: close what is still open.
                        for slot in open.keys.sorted() {
                            while open[slot]?.isEmpty == false {
                                close(channel: UInt8(slot >> 8), key: UInt8(slot & 0xFF))
                            }
                        }
                        return track
                    default:
                        break
                    }
                    continue
                }
                if byte == 0xF0 || byte == 0xF7 {
                    try reader.skip(Int(try reader.variableLength()))
                    status = nil
                    continue
                }
                if byte >= 0x80 {
                    status = byte
                    byte = try reader.uint8()
                } else if status == nil {
                    throw SongImportError.damaged("a MIDI event has no status byte")
                }
                guard let status else { continue }
                let kind = status & 0xF0
                let channel = status & 0x0F
                var second: UInt8 = 0
                if kind != 0xC0 && kind != 0xD0 {
                    second = try reader.uint8()
                }
                // Channel 10 (9 from zero) is drums in General MIDI.
                guard channel != 9 else { continue }
                switch kind {
                case 0x90 where second > 0:
                    open[Int(channel) << 8 | Int(byte), default: []].append(tick)
                case 0x90, 0x80:
                    close(channel: channel, key: byte)
                default:
                    break
                }
            }
            for slot in open.keys.sorted() {
                while open[slot]?.isEmpty == false {
                    close(channel: UInt8(slot >> 8), key: UInt8(slot & 0xFF))
                }
            }
            return track
        }
    }
}

/// Reads big-endian numbers from bytes, and throws at the end instead of
/// crashing.
struct ByteReader {
    private let bytes: [UInt8]
    private(set) var offset = 0

    init(_ bytes: [UInt8]) {
        self.bytes = bytes
    }

    var atEnd: Bool { offset >= bytes.count }

    mutating func uint8() throws -> UInt8 {
        guard offset < bytes.count else { throw SongImportError.damaged("the MIDI file ends too soon") }
        defer { offset += 1 }
        return bytes[offset]
    }

    mutating func uint16() throws -> UInt16 {
        let high = try uint8()
        let low = try uint8()
        return UInt16(high) << 8 | UInt16(low)
    }

    mutating func uint32() throws -> UInt32 {
        let high = try uint16()
        let low = try uint16()
        return UInt32(high) << 16 | UInt32(low)
    }

    mutating func bytes(_ count: Int) throws -> [UInt8] {
        guard count >= 0, count <= bytes.count - offset else {
            throw SongImportError.damaged("the MIDI file ends too soon")
        }
        defer { offset += count }
        return Array(bytes[offset..<offset + count])
    }

    mutating func skip(_ count: Int) throws {
        _ = try bytes(count)
    }

    mutating func tag() throws -> String {
        String(decoding: try bytes(4), as: UTF8.self)
    }

    /// A MIDI variable-length number: 7 bits a byte, at most 4 bytes.
    mutating func variableLength() throws -> UInt32 {
        var value: UInt32 = 0
        for _ in 0..<4 {
            let byte = try uint8()
            value = value << 7 | UInt32(byte & 0x7F)
            if byte & 0x80 == 0 { return value }
        }
        throw SongImportError.damaged("a MIDI length is longer than 4 bytes")
    }
}
