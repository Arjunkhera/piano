import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

/// Reads an uncompressed MusicXML file (score-partwise) into a song.
///
/// It plays the score as written, once: it does not follow repeats. Grace
/// notes have no length in MusicXML, so it leaves them out. Tied notes become
/// one long note.
///
/// The hand of each note:
/// 1. A part with two staves: staff 1 is the right hand, staff 2 the left.
/// 2. Else, when exactly two parts hold notes, the first is the right hand.
/// 3. Else, keys below middle C go to the left hand.
public enum MusicXMLReader {
    public static func read(_ data: Data) throws -> ImportedSong {
        let reader = Reader()
        let parser = XMLParser(data: data)
        parser.shouldResolveExternalEntities = false
        parser.delegate = reader
        let finished = parser.parse()
        if let problem = reader.problem { throw problem }
        guard finished else {
            let why = parser.parserError.map { "\($0.localizedDescription)" } ?? "the XML is not valid"
            throw SongImportError.damaged(why)
        }
        guard reader.sawScore else { throw SongImportError.unknownFormat }
        // Some XML parsers accept a file that stops part way. Check for the end tag.
        guard reader.closedScore else { throw SongImportError.damaged("the score ends too soon") }

        let pitchedParts = reader.parts.filter { !$0.notes.isEmpty }
        var notes: [Note] = []
        for (index, part) in pitchedParts.enumerated() {
            let byStaff = part.notes.contains { ($0.staff ?? 1) >= 2 }
            for raw in part.notes {
                let hand: Note.Hand
                if byStaff {
                    hand = (raw.staff ?? 1) >= 2 ? .left : .right
                } else if pitchedParts.count == 2 {
                    hand = index == 0 ? .right : .left
                } else {
                    hand = Note.handBySplit(raw.key)
                }
                notes.append(Note(key: raw.key, start: raw.start, length: raw.length, hand: hand))
            }
        }
        return ImportedSong(
            title: reader.workTitle ?? reader.movementTitle ?? "",
            beatsPerMinute: reader.tempo ?? 120,
            beatsPerBar: reader.meter ?? 4,
            notes: notes.sortedForSong()
        )
    }

    /// The MIDI key of a written pitch: C4 is 60.
    static func key(step: String, alter: Double, octave: Int) -> Int? {
        let steps: [String: Int] = ["C": 0, "D": 2, "E": 4, "F": 5, "G": 7, "A": 9, "B": 11]
        guard let base = steps[step.uppercased()] else { return nil }
        return (octave + 1) * 12 + base + Int(alter.rounded())
    }

    struct RawNote {
        var key: UInt8
        var start: Double
        var length: Double
        var staff: Int?
    }

    struct Part {
        var notes: [RawNote] = []
    }

    final class Reader: NSObject, XMLParserDelegate {
        var parts: [Part] = []
        var workTitle: String?
        var movementTitle: String?
        var tempo: Double?
        var meter: Double?
        var sawScore = false
        var closedScore = false
        var problem: SongImportError?

        private var path: [String] = []
        private var text = ""

        // The part being read. Time is in beats (quarter notes).
        private var divisions = 1.0
        private var position = 0.0
        private var lastStart = 0.0
        private var measureEnd = 0.0
        private var timeBeats: Double?

        // The note being read.
        private var isChord = false
        private var isRest = false
        private var isGrace = false
        private var isCue = false
        private var step: String?
        private var alter = 0.0
        private var octave: Int?
        private var duration = 0.0
        private var staff: Int?
        private var tieStop = false

        func parser(
            _ parser: XMLParser,
            didStartElement name: String,
            namespaceURI: String?,
            qualifiedName: String?,
            attributes: [String: String] = [:]
        ) {
            path.append(name)
            text = ""
            switch name {
            case "score-partwise":
                sawScore = true
            case "score-timewise":
                problem = .unsupported("the score is in timewise MusicXML; save it as partwise")
                parser.abortParsing()
            case "part" where path.count == 2:
                parts.append(Part())
                divisions = 1
                position = 0
                lastStart = 0
                measureEnd = 0
            case "measure":
                measureEnd = position
            case "note":
                isChord = false
                isRest = false
                isGrace = false
                isCue = false
                step = nil
                alter = 0
                octave = nil
                duration = 0
                staff = nil
                tieStop = false
            case "chord": isChord = true
            case "rest": isRest = true
            case "grace": isGrace = true
            case "cue": isCue = true
            case "tie" where attributes["type"] == "stop": tieStop = true
            case "sound":
                if tempo == nil, let value = attributes["tempo"].flatMap(Double.init), value > 0 {
                    tempo = value
                }
            default:
                break
            }
        }

        func parser(_ parser: XMLParser, foundCharacters string: String) {
            text += string
        }

        func parser(
            _ parser: XMLParser,
            didEndElement name: String,
            namespaceURI: String?,
            qualifiedName: String?
        ) {
            let value = text.trimmingCharacters(in: .whitespacesAndNewlines)
            let parent = path.count >= 2 ? path[path.count - 2] : ""
            switch name {
            case "work-title" where workTitle == nil: workTitle = value
            case "movement-title" where movementTitle == nil: movementTitle = value
            case "divisions":
                if let number = Double(value), number > 0 { divisions = number }
            case "beats" where parent == "time":
                // "3+2" means 5 beats.
                timeBeats = value.split(separator: "+").compactMap { Double($0) }.reduce(0, +)
            case "beat-type" where parent == "time":
                if meter == nil, let beats = timeBeats, let type = Double(value), type > 0 {
                    meter = beats * 4 / type
                }
            case "step" where parent == "pitch": step = value
            case "alter" where parent == "pitch": alter = Double(value) ?? 0
            case "octave" where parent == "pitch": octave = Int(value)
            case "staff" where parent == "note": staff = Int(value)
            case "duration":
                let beats = (Double(value) ?? 0) / divisions
                switch parent {
                case "note": duration = beats
                case "backup": position -= beats
                case "forward":
                    position += beats
                    measureEnd = max(measureEnd, position)
                default: break
                }
            case "note":
                endNote()
            case "measure":
                position = max(position, measureEnd)
            case "score-partwise":
                closedScore = true
            default:
                break
            }
            path.removeLast()
            text = ""
        }

        private func endNote() {
            guard !isGrace, !parts.isEmpty else { return }
            let start = isChord ? lastStart : position
            if !isChord {
                lastStart = position
                position += duration
                measureEnd = max(measureEnd, position)
            }
            guard !isRest, !isCue, let step, let octave,
                  let key = MusicXMLReader.key(step: step, alter: alter, octave: octave),
                  key >= Int(pianoKeys.lowerBound), key <= Int(pianoKeys.upperBound)
            else { return }
            let midiKey = UInt8(key)
            let part = parts.count - 1
            if tieStop, let held = parts[part].notes.lastIndex(where: {
                $0.key == midiKey && $0.staff == staff && abs($0.start + $0.length - start) < 0.0001
            }) {
                parts[part].notes[held].length += duration
                return
            }
            parts[part].notes.append(RawNote(key: midiKey, start: start, length: duration, staff: staff))
        }
    }
}
