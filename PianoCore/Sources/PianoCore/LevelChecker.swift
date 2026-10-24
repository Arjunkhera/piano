/// One place where a lesson breaks a rule of its level.
public struct Breach: Equatable, Sendable {
    public enum Rule: String, Sendable {
        /// A key is off the 88-key piano.
        case keyRange
        /// One hand holds too many keys at once.
        case tooManyAtOnce
        /// One hand holds keys too far apart at once.
        case tooWide
        /// A start or a length is off the rhythm grid of the level.
        case offGrid
        case tooShort
        case tooLong
        /// A black key in a level that uses white keys only.
        case blackKey
        /// A key outside the hand position of the level.
        case outsidePosition
        /// The key of the lesson has too many sharps or flats.
        case keyTooHard
    }

    public var rule: Rule
    /// The note that breaks the rule. Nil for a rule about the whole lesson.
    public var note: Note?
    public var detail: String
}

/// Checks a lesson against the rules of its level. It is separate from the
/// lesson maker, so a bug in the maker shows as a breach.
public enum LevelChecker {
    // Lengths come from subtractions, so allow a tiny rounding error.
    private static let tolerance = 1e-6

    /// The breaches of the lesson. An empty list means the lesson obeys
    /// every rule of its level.
    public static func check(_ lesson: Lesson) -> [Breach] {
        check(lesson.notes, level: lesson.level, key: lesson.key)
    }

    /// The breaches of a list of notes at a level. With no key given, the
    /// checker finds the key from the notes.
    public static func check(_ notes: [Note], level: Level, key: MusicKey? = nil) -> [Breach] {
        let rules = level.rules
        var breaches: [Breach] = []

        let songKey = key ?? MusicKey.find(in: notes)
        if let limit = rules.maxAccidentals, songKey.accidentals > limit {
            breaches.append(Breach(rule: .keyTooHard, note: nil,
                                   detail: "\(songKey.name) has \(songKey.accidentals) sharps or flats; the limit is \(limit)"))
        }

        for note in notes {
            let name = KeyName.name(of: note.key)
            if !pianoKeys.contains(note.key) {
                breaches.append(Breach(rule: .keyRange, note: note, detail: "key \(note.key) is off the piano"))
            }
            if rules.whiteKeysOnly && KeyName.isBlack(note.key) {
                breaches.append(Breach(rule: .blackKey, note: note, detail: "\(name) is a black key"))
            }
            let place = note.hand == .right ? rules.rightHandKeys : rules.leftHandKeys
            if let place, !place.contains(note.key) {
                breaches.append(Breach(rule: .outsidePosition, note: note,
                                       detail: "\(name) is outside the \(note.hand.rawValue) hand position"))
            }
            if let grid = rules.grid, !onGrid(note.start, grid) || !onGrid(note.length, grid) {
                breaches.append(Breach(rule: .offGrid, note: note,
                                       detail: "\(name) at beat \(note.start) is off the \(grid)-beat grid"))
            }
            if note.length < rules.shortest - tolerance {
                breaches.append(Breach(rule: .tooShort, note: note,
                                       detail: "\(name) lasts \(note.length) beats; the shortest is \(rules.shortest)"))
            }
            if let longest = rules.longest, note.length > longest + tolerance {
                breaches.append(Breach(rule: .tooLong, note: note,
                                       detail: "\(name) lasts \(note.length) beats; the longest is \(longest)"))
            }
        }

        for hand in [Note.Hand.right, .left] {
            let handNotes = notes.filter { $0.hand == hand }
            for start in Set(handNotes.map(\.start)).sorted() {
                let keys = handNotes
                    .filter { $0.start <= start && $0.start + $0.length > start + tolerance }
                    .map { Int($0.key) }
                guard let low = keys.min(), let high = keys.max() else { continue }
                if keys.count > rules.maxAtOnce {
                    breaches.append(Breach(rule: .tooManyAtOnce, note: nil,
                                           detail: "the \(hand.rawValue) hand holds \(keys.count) keys at beat \(start); the limit is \(rules.maxAtOnce)"))
                }
                if high - low > rules.maxSpan {
                    breaches.append(Breach(rule: .tooWide, note: nil,
                                           detail: "the \(hand.rawValue) hand spans \(high - low) keys at beat \(start); the limit is \(rules.maxSpan)"))
                }
            }
        }
        return breaches
    }

    private static func onGrid(_ value: Double, _ grid: Double) -> Bool {
        let steps = value / grid
        return abs(steps - steps.rounded()) < tolerance
    }
}
