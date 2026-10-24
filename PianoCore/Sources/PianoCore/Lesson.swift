/// One song at one level: the notes to play, and how the maker changed the
/// song to make them.
public struct Lesson: Equatable, Codable, Sendable {
    public var level: Level
    /// The notes, in order of start, then key.
    public var notes: [Note]
    /// The key of the lesson, after the move.
    public var key: MusicKey
    /// How many keys the maker moved the song. -2 means two keys down.
    public var shift: Int
    public var beatsPerBar: Int

    public init(level: Level, notes: [Note], key: MusicKey, shift: Int, beatsPerBar: Int) {
        self.level = level
        self.notes = notes
        self.key = key
        self.shift = shift
        self.beatsPerBar = beatsPerBar
    }
}
