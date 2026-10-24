/// A few bars of a lesson. You practise one part at a time.
public struct LessonPart: Equatable, Sendable {
    /// The number of the part, from 1.
    public var number: Int
    /// The first bar of the part, from 1.
    public var firstBar: Int
    /// How many bars the part holds.
    public var bars: Int
    /// The notes that start in the bars of the part.
    public var notes: [Note]

    public init(number: Int, firstBar: Int, bars: Int, notes: [Note]) {
        self.number = number
        self.firstBar = firstBar
        self.bars = bars
        self.notes = notes
    }
}

extension Lesson {
    /// The lesson cut into parts of `barsEach` bars. A note belongs to the
    /// part where it starts. A part with no notes, such as a rest, is kept,
    /// so that the part numbers follow the bars.
    public func parts(barsEach: Int = 4) -> [LessonPart] {
        let bars = max(1, barsEach)
        let partLength = Double(max(1, beatsPerBar) * bars)
        var byPart: [Int: [Note]] = [:]
        for note in notes {
            byPart[Int((note.start / partLength).rounded(.down)), default: []].append(note)
        }
        guard let last = byPart.keys.max() else { return [] }
        return (0...last).map { index in
            LessonPart(number: index + 1, firstBar: index * bars + 1, bars: bars, notes: byPart[index] ?? [])
        }
    }
}
