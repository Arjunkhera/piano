/// The hands to practise.
public enum Hands: String, CaseIterable, Codable, Sendable {
    case right
    case left
    case both

    /// True when a note of `hand` is in the practice.
    public func includes(_ hand: Note.Hand) -> Bool {
        switch self {
        case .right: return hand == .right
        case .left: return hand == .left
        case .both: return true
        }
    }
}

/// The notes that start on the same beat. In wait mode you press each key
/// of a step, in any order, before the next step starts.
public struct PracticeStep: Equatable, Sendable {
    /// Where the step starts, in beats.
    public var beat: Double
    /// The keys to press.
    public var keys: Set<UInt8>
    /// The notes of the step, in order of key.
    public var notes: [Note]

    public init(beat: Double, keys: Set<UInt8>, notes: [Note]) {
        self.beat = beat
        self.keys = keys
        self.notes = notes
    }

    /// The steps of `notes` for `hands`, in order of beat. Notes that start
    /// on the same beat make one step.
    public static func steps(from notes: [Note], hands: Hands = .both) -> [PracticeStep] {
        var byBeat: [Int: [Note]] = [:]
        for note in notes where hands.includes(note.hand) {
            // Starts come from a grid, but compare them in millionths of a
            // beat so that a rounding error does not split a chord.
            byBeat[Int((note.start * 1_000_000).rounded()), default: []].append(note)
        }
        return byBeat.keys.sorted().map { tick in
            let notes = byBeat[tick]!.sorted { $0.key < $1.key }
            return PracticeStep(beat: Double(tick) / 1_000_000, keys: Set(notes.map(\.key)), notes: notes)
        }
    }
}
