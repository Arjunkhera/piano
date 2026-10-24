/// Makes a lesson at one level from the master score of a song. The rules
/// are fixed and the same score always gives the same lesson. Each lesson
/// obeys the rules of its level, and `LevelChecker` proves it.
public enum LessonMaker {
    /// Makes the lesson at `level`. The score is every note of the song, at
    /// full difficulty. Notes with no length, a start before 0 or a key off
    /// the piano are dropped first.
    public static func make(_ level: Level, from score: [Note], beatsPerBar: Int = 4) -> Lesson {
        let barLength = max(1, beatsPerBar)
        let clean = score.filter { $0.length > 0 && $0.start >= 0 && pianoKeys.contains($0.key) }
        let songKey = MusicKey.find(in: clean)
        let shift = self.shift(for: level, from: songKey)
        let moved = clean.map { move($0, by: shift) }

        let notes: [Note]
        switch level {
        case .beginner:
            notes = beginner(moved, barLength: Double(barLength))
        case .intermediate:
            notes = intermediate(moved, barLength: Double(barLength))
        case .advanced:
            notes = advanced(moved)
        }
        return Lesson(level: level, notes: notes.sorted(by: playOrder), key: songKey.moved(by: shift),
                      shift: shift, beatsPerBar: barLength)
    }

    /// The lessons at all three levels.
    public static func makeAll(from score: [Note], beatsPerBar: Int = 4) -> [Lesson] {
        Level.allCases.map { make($0, from: score, beatsPerBar: beatsPerBar) }
    }

    // MARK: - Key

    /// Beginner: move to C major or A minor. Intermediate: move by the
    /// fewest keys to a key with at most 3 sharps or flats. Advanced: keep
    /// the key.
    static func shift(for level: Level, from key: MusicKey) -> Int {
        switch level {
        case .beginner:
            let target = key.mode == .major ? 0 : 9
            let up = ((target - key.tonic) % 12 + 12) % 12
            return up > 5 ? up - 12 : up
        case .intermediate:
            let limit = Level.intermediate.rules.maxAccidentals ?? 6
            for shift in [0, -1, 1, -2, 2, -3, 3, -4, 4, -5, 5, -6] where key.moved(by: shift).accidentals <= limit {
                return shift
            }
            return 0
        case .advanced:
            return 0
        }
    }

    /// Moves a note by `shift` keys, then by octaves until it is on the piano.
    static func move(_ note: Note, by shift: Int) -> Note {
        var key = Int(note.key) + shift
        while key < Int(pianoKeys.lowerBound) { key += 12 }
        while key > Int(pianoKeys.upperBound) { key -= 12 }
        var moved = note
        moved.key = UInt8(key)
        return moved
    }

    // MARK: - Beginner

    // Middle C position: the right hand plays C4 to G4 with fingers 1 to 5.
    // The left hand plays A3 and B3 with fingers 3 and 2.
    private static let rightHandPlace: [Int: (key: UInt8, finger: Int)] = [
        0: (60, 1), 2: (62, 2), 4: (64, 3), 5: (65, 4), 7: (67, 5),
    ]
    private static let leftHandPlace: [Int: (key: UInt8, finger: Int)] = [
        9: (57, 3), 11: (59, 2),
    ]

    /// The melody only, one note at a time, on the beat, in middle C
    /// position. The highest key at each beat is the melody. A black key
    /// becomes the white key below it. Each note moves by octaves into
    /// middle C position. A and B go to the left hand.
    static func beginner(_ notes: [Note], barLength: Double) -> [Note] {
        var top: [Double: Note] = [:]
        for note in notes {
            let beat = note.start.rounded()
            if let held = top[beat], held.key >= note.key { continue }
            top[beat] = note
        }
        let beats = top.keys.sorted()
        var lesson: [Note] = []
        for (index, beat) in beats.enumerated() {
            let source = top[beat]!
            let barEnd = ((beat / barLength).rounded(.down) + 1) * barLength
            var length = min(max(1, source.length.rounded()), barEnd - beat, 4)
            if index + 1 < beats.count {
                length = min(length, beats[index + 1] - beat)
            }
            var pitchClass = Int(source.key) % 12
            if KeyName.isBlack(source.key) { pitchClass -= 1 }
            if let place = rightHandPlace[pitchClass] {
                lesson.append(Note(key: place.key, start: beat, length: length, hand: .right, finger: place.finger))
            } else if let place = leftHandPlace[pitchClass] {
                lesson.append(Note(key: place.key, start: beat, length: length, hand: .left, finger: place.finger))
            }
        }
        return lesson
    }

    // MARK: - Intermediate

    /// The right hand keeps its top two keys at each start, snapped to the
    /// eighth note. The left hand plays the root and fifth of the chord of
    /// each bar, held for the bar, below the right hand.
    static func intermediate(_ notes: [Note], barLength: Double) -> [Note] {
        let rules = Level.intermediate.rules
        let grid = rules.grid ?? 0.5
        let snapped = notes.map { note -> Note in
            var snapped = note
            snapped.start = snap(note.start, to: grid)
            snapped.length = max(grid, snap(note.start + note.length, to: grid) - snapped.start)
            snapped.finger = nil
            return snapped
        }
        let rightSource = snapped.contains { $0.hand == .right } ? snapped.filter { $0.hand == .right } : snapped
        let right = fit(rightSource.map { var note = $0; note.hand = .right; return note },
                        maxAtOnce: rules.maxAtOnce, maxSpan: rules.maxSpan, keepTop: true)

        var left: [Note] = []
        let lastEnd = snapped.map { $0.start + $0.length }.max() ?? 0
        var bar = 0
        while Double(bar) * barLength < lastEnd {
            let barStart = Double(bar) * barLength
            let barEnd = barStart + barLength
            bar += 1
            guard let root = chordRoot(snapped, from: barStart, to: barEnd) else { continue }
            var rootKey = 48 + root
            let rightLowest = right
                .filter { $0.start < barEnd && $0.start + $0.length > barStart }
                .map { Int($0.key) }
                .min() ?? Int.max
            while rootKey + 7 >= rightLowest && rootKey - 12 >= Int(pianoKeys.lowerBound) {
                rootKey -= 12
            }
            if rootKey < rightLowest {
                left.append(Note(key: UInt8(rootKey), start: barStart, length: barLength, hand: .left))
            }
            if rootKey + 7 < rightLowest {
                left.append(Note(key: UInt8(rootKey + 7), start: barStart, length: barLength, hand: .left))
            }
        }
        return right + fit(left, maxAtOnce: rules.maxAtOnce, maxSpan: rules.maxSpan, keepTop: false)
    }

    /// The root of the major or minor chord that best fits the notes that
    /// sound in a bar, as a pitch class. Each note counts by the beats it
    /// sounds in the bar. The lowest key of the bar breaks a tie. Nil for an
    /// empty bar.
    static func chordRoot(_ notes: [Note], from barStart: Double, to barEnd: Double) -> Int? {
        var weights = [Double](repeating: 0, count: 12)
        var lowest: UInt8?
        for note in notes {
            let sounds = min(note.start + note.length, barEnd) - max(note.start, barStart)
            guard sounds > 0 else { continue }
            weights[Int(note.key) % 12] += sounds
            lowest = min(lowest ?? note.key, note.key)
        }
        guard let bass = lowest else { return nil }
        let bassBonus = 0.01 * weights.reduce(0, +)
        var best = 0
        var bestScore = -1.0
        for root in 0..<12 {
            for third in [4, 3] {
                var score = weights[root] + weights[(root + third) % 12] + weights[(root + 7) % 12]
                if Int(bass) % 12 == root { score += bassBonus }
                if score > bestScore {
                    bestScore = score
                    best = root
                }
            }
        }
        return best
    }

    // MARK: - Advanced

    /// The song as written, in its own key. Notes shorter than a 32nd note
    /// are dropped. Each hand holds at most 5 keys, inside a 9th.
    static func advanced(_ notes: [Note]) -> [Note] {
        let rules = Level.advanced.rules
        let long = notes.filter { $0.length >= rules.shortest }
        let right = fit(long.filter { $0.hand == .right }, maxAtOnce: rules.maxAtOnce, maxSpan: rules.maxSpan, keepTop: true)
        let left = fit(long.filter { $0.hand == .left }, maxAtOnce: rules.maxAtOnce, maxSpan: rules.maxSpan, keepTop: false)
        return (right + left).filter { $0.length >= rules.shortest }
    }

    // MARK: - Shared steps

    /// Makes one hand playable. At each start, it keeps at most `maxAtOnce`
    /// keys inside `maxSpan`: the top keys for the right hand, the bottom
    /// keys for the left hand. A held note that breaks a limit ends where
    /// the new notes start.
    static func fit(_ notes: [Note], maxAtOnce: Int, maxSpan: Int, keepTop: Bool) -> [Note] {
        let starts = Set(notes.map(\.start)).sorted()
        var kept: [Note] = []
        for start in starts {
            var byKey: [UInt8: Note] = [:]
            for note in notes where note.start == start {
                if (byKey[note.key]?.length ?? 0) < note.length { byKey[note.key] = note }
            }
            let ordered = byKey.values.sorted { keepTop ? $0.key > $1.key : $0.key < $1.key }
            var group: [Note] = []
            for note in ordered where group.count < maxAtOnce {
                if let first = group.first, abs(Int(first.key) - Int(note.key)) > maxSpan { continue }
                group.append(note)
            }

            // Held notes, the newest first, stay while every limit holds.
            var sounding = group.map { Int($0.key) }
            let held = kept.indices
                .filter { kept[$0].start < start && kept[$0].start + kept[$0].length > start }
                .sorted { kept[$0].start > kept[$1].start }
            for index in held {
                let key = Int(kept[index].key)
                let keys = sounding + [key]
                if !sounding.contains(key) && keys.count <= maxAtOnce
                    && keys.max()! - keys.min()! <= maxSpan {
                    sounding.append(key)
                } else {
                    kept[index].length = start - kept[index].start
                }
            }
            kept += group
        }
        return kept
    }

    static func snap(_ value: Double, to grid: Double) -> Double {
        (value / grid).rounded() * grid
    }

    static func playOrder(_ a: Note, _ b: Note) -> Bool {
        a.start != b.start ? a.start < b.start : a.key < b.key
    }
}
