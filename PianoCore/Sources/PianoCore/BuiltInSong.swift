/// A tune that ships with the app, so there is something to practise before
/// a song comes in. Each one is free to use, and it is a few lines of code,
/// not a song file.
public struct BuiltInSong: Identifiable, Sendable {
    public var id: String
    public var title: String
    public var beatsPerBar: Int
    /// The master score: the right-hand tune, in C major.
    public var notes: [Note]

    /// Every built-in tune.
    public static let all: [BuiltInSong] = [twinkle, odeToJoy, cMajorScale]

    /// "Twinkle, Twinkle, Little Star", a folk tune.
    public static let twinkle = BuiltInSong(
        id: "twinkle", title: "Twinkle, Twinkle, Little Star", beatsPerBar: 4,
        notes: tune([
            (60, 1), (60, 1), (67, 1), (67, 1), (69, 1), (69, 1), (67, 2),
            (65, 1), (65, 1), (64, 1), (64, 1), (62, 1), (62, 1), (60, 2),
            (67, 1), (67, 1), (65, 1), (65, 1), (64, 1), (64, 1), (62, 2),
            (67, 1), (67, 1), (65, 1), (65, 1), (64, 1), (64, 1), (62, 2),
            (60, 1), (60, 1), (67, 1), (67, 1), (69, 1), (69, 1), (67, 2),
            (65, 1), (65, 1), (64, 1), (64, 1), (62, 1), (62, 1), (60, 2),
        ]))

    /// "Ode to Joy", the tune from Beethoven's ninth symphony.
    public static let odeToJoy = BuiltInSong(
        id: "ode-to-joy", title: "Ode to Joy", beatsPerBar: 4,
        notes: tune([
            (64, 1), (64, 1), (65, 1), (67, 1), (67, 1), (65, 1), (64, 1), (62, 1),
            (60, 1), (60, 1), (62, 1), (64, 1), (64, 1.5), (62, 0.5), (62, 2),
            (64, 1), (64, 1), (65, 1), (67, 1), (67, 1), (65, 1), (64, 1), (62, 1),
            (60, 1), (60, 1), (62, 1), (64, 1), (62, 1.5), (60, 0.5), (60, 2),
        ]))

    /// The C major scale, up and down one octave.
    public static let cMajorScale = BuiltInSong(
        id: "c-major-scale", title: "C major scale", beatsPerBar: 4,
        notes: tune([
            (60, 1), (62, 1), (64, 1), (65, 1), (67, 1), (69, 1), (71, 1), (72, 1),
            (71, 1), (69, 1), (67, 1), (65, 1), (64, 1), (62, 1), (60, 2),
        ]))

    /// Right-hand notes, one after the other, from (key, beats) pairs.
    private static func tune(_ notes: [(key: UInt8, beats: Double)]) -> [Note] {
        var start = 0.0
        return notes.map { note in
            defer { start += note.beats }
            return Note(key: note.key, start: start, length: note.beats, hand: .right)
        }
    }
}
