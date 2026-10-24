/// The score of one part in wait mode, and one tip on the tempo.
public struct PracticeScore: Equatable, Sendable {
    /// The notes to play.
    public var notes: Int
    /// The notes of each step that had no wrong key. A late note is still right.
    public var right: Int
    /// The presses of keys that were not in the step.
    public var wrongKeys: Int
    /// The right keys that were late.
    public var late: Int
    /// The tempo of the practice, in beats per minute.
    public var tempo: Int

    public init(notes: Int, right: Int, wrongKeys: Int, late: Int, tempo: Int) {
        self.notes = notes
        self.right = right
        self.wrongKeys = wrongKeys
        self.late = late
        self.tempo = tempo
    }

    /// One line, such as "13 of 14 right. 1 wrong key. 0 late."
    public var summary: String {
        guard notes > 0 else { return "No notes to play." }
        return "\(right) of \(notes) right. \(wrongKeys) wrong \(wrongKeys == 1 ? "key" : "keys"). \(late) late."
    }

    /// What to try next. Faster: 90 percent or more right and 10 percent or
    /// fewer late. Again: 70 percent or more right. Slower: less.
    public var tip: Tip {
        let tempos = WaitMode.tempos
        if notes > 0 && right * 10 >= notes * 9 && late * 10 <= notes {
            let next = min(tempo + 10, tempos.upperBound)
            return Tip(kind: .faster, tempo: next, text: "Well done. Try it at \(next) beats per minute.")
        }
        if notes == 0 || right * 10 >= notes * 7 {
            return Tip(kind: .again, tempo: tempo, text: "Play it again at \(tempo) beats per minute.")
        }
        let next = max(tempo - 10, tempos.lowerBound)
        return Tip(kind: .slower, tempo: next, text: "Try it slower, at \(next) beats per minute.")
    }
}

/// The one line after a score that says what tempo to try next.
public struct Tip: Equatable, Sendable {
    public enum Kind: String, Sendable {
        case faster
        case again
        case slower
    }

    public var kind: Kind
    /// The tempo to try next, in beats per minute.
    public var tempo: Int
    public var text: String
}
