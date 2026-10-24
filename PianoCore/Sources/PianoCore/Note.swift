/// One note of a song. D2 writes notes, D3 makes levels from them, and D4
/// checks key presses against them.
public struct Note: Equatable, Hashable, Codable, Sendable {
    public enum Hand: String, Codable, Sendable {
        case left
        case right
    }

    /// The MIDI key number, 21 to 108.
    public var key: UInt8
    /// When the note starts, in beats from the start of the song.
    public var start: Double
    /// How long the note lasts, in beats.
    public var length: Double
    public var hand: Hand
    /// The finger, 1 (thumb) to 5 (little finger), when known.
    public var finger: Int?

    public init(key: UInt8, start: Double, length: Double, hand: Hand, finger: Int? = nil) {
        self.key = key
        self.start = start
        self.length = length
        self.hand = hand
        self.finger = finger
    }
}
