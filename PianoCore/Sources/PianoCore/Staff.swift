/// The two staves of piano music.
public enum Clef: String, Codable, Sendable {
    /// The top staff, mostly for the right hand. Its bottom line is E4.
    case treble
    /// The bottom staff, mostly for the left hand. Its bottom line is G2.
    case bass

    /// The clef for the notes of a hand.
    public static func of(_ hand: Note.Hand) -> Clef {
        hand == .right ? .treble : .bass
    }
}

/// Where a white key sits on a staff. A step is one line or one space:
/// step 0 is the bottom line, step 1 the space above it, and step 8 the
/// top line. Steps below 0 or above 8 need small lines of their own, the
/// ledger lines.
public enum Staff {
    /// The top line of a staff.
    public static let topLine = 8

    /// The place of each white key in its octave: C is 0, D is 1, up to B, 6.
    private static let letterIndex: [Int: Int] = [0: 0, 2: 1, 4: 2, 5: 3, 7: 4, 9: 5, 11: 6]

    /// The white key on the bottom line of each clef.
    private static func bottomLine(_ clef: Clef) -> UInt8 {
        clef == .treble ? 64 : 43
    }

    /// The count of white keys from C-1 up to `key`. Nil for a black key.
    private static func whiteIndex(of key: UInt8) -> Int? {
        guard let letter = letterIndex[Int(key) % 12] else { return nil }
        return (Int(key) / 12) * 7 + letter
    }

    /// The step of `key` on the staff of `clef`. Nil for a black key, which
    /// the basics course does not show on a staff.
    public static func step(of key: UInt8, clef: Clef) -> Int? {
        guard let index = whiteIndex(of: key), let bottom = whiteIndex(of: bottomLine(clef)) else { return nil }
        return index - bottom
    }

    /// The ledger lines that a note on `step` needs, as steps. Middle C on
    /// the treble staff, step -2, needs one line at -2.
    public static func ledgerLines(for step: Int) -> [Int] {
        if step <= -2 { return Array(stride(from: -2, through: step, by: -2)) }
        if step >= topLine + 2 { return Array(stride(from: topLine + 2, through: step, by: 2)) }
        return []
    }
}
