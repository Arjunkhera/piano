/// The three levels of a lesson. Each level has fixed rules, taken from the
/// Alfred and ABRSM levelling guides. D3 makes a lesson at each level from
/// one master score.
public enum Level: String, CaseIterable, Codable, Sendable {
    case beginner
    case intermediate
    case advanced

    /// The rules that every lesson at this level obeys.
    public var rules: LevelRules {
        switch self {
        case .beginner:
            return LevelRules(maxAtOnce: 1, maxSpan: 7, grid: 1, shortest: 1, longest: 4,
                              maxAccidentals: 0, whiteKeysOnly: true,
                              rightHandKeys: 60...67, leftHandKeys: 53...59)
        case .intermediate:
            return LevelRules(maxAtOnce: 2, maxSpan: 12, grid: 0.5, shortest: 0.5, longest: nil,
                              maxAccidentals: 3, whiteKeysOnly: false,
                              rightHandKeys: nil, leftHandKeys: nil)
        case .advanced:
            return LevelRules(maxAtOnce: 5, maxSpan: 14, grid: nil, shortest: 0.125, longest: nil,
                              maxAccidentals: nil, whiteKeysOnly: false,
                              rightHandKeys: nil, leftHandKeys: nil)
        }
    }
}

/// The limits of one level. The lesson maker obeys them and the level
/// checker tests them.
public struct LevelRules: Equatable, Sendable {
    /// The most keys that one hand holds down at the same time.
    public var maxAtOnce: Int
    /// The widest distance, in keys, between the keys one hand holds down
    /// at the same time. 7 is a 5th, 12 is an octave, 14 is a 9th.
    public var maxSpan: Int
    /// Each start and each length is a whole number of this many beats.
    /// Nil means any rhythm.
    public var grid: Double?
    /// The shortest note, in beats.
    public var shortest: Double
    /// The longest note, in beats. Nil means no limit.
    public var longest: Double?
    /// The most sharps or flats in the key. Nil means any key.
    public var maxAccidentals: Int?
    /// True means white keys only.
    public var whiteKeysOnly: Bool
    /// The keys the right hand may play. Nil means any key.
    public var rightHandKeys: ClosedRange<UInt8>?
    /// The keys the left hand may play. Nil means any key.
    public var leftHandKeys: ClosedRange<UInt8>?
}
