/// Classical pieces that ship with the app. Each composer died more than a
/// hundred years ago, so the music is in the public domain. The notes are
/// written by hand here, as a short, simple arrangement: the tune in the
/// right hand and a few low notes in the left hand. The lesson maker makes
/// the easier and harder levels from these notes.
extension BuiltInSong {
    /// Every classical piece, in the order of the list.
    public static let classical: [BuiltInSong] = [beethovenFifth, furElise, minuetInG, canonInD]

    /// The main theme of the first part of Beethoven's fifth symphony, in
    /// C minor, two beats in a bar.
    public static let beethovenFifth = BuiltInSong(
        id: "beethoven-fifth", title: "Symphony No. 5, main theme", beatsPerBar: 2,
        notes: hand(.right, [
            // The four-note call, two times.
            (rest, 0.5), (67, 0.5), (67, 0.5), (67, 0.5), (63, 4),
            (rest, 0.5), (65, 0.5), (65, 0.5), (65, 0.5), (62, 4),
            // The answer climbs, two times.
            (rest, 0.5), (67, 0.5), (67, 0.5), (67, 0.5), (68, 0.5), (68, 0.5), (68, 0.5), (67, 0.5),
            (rest, 0.5), (75, 0.5), (75, 0.5), (75, 0.5), (72, 2),
            (rest, 0.5), (67, 0.5), (67, 0.5), (67, 0.5), (68, 0.5), (68, 0.5), (68, 0.5), (67, 0.5),
            (rest, 0.5), (77, 0.5), (77, 0.5), (77, 0.5), (74, 2),
            // The call again, then the end on C.
            (rest, 0.5), (67, 0.5), (67, 0.5), (67, 0.5), (63, 2),
            (rest, 0.5), (65, 0.5), (65, 0.5), (65, 0.5), (62, 2),
            (60, 4),
        ]) + hand(.left, [
            (rest, 2), (48, 4),
            (rest, 2), (43, 4),
            (48, 2), (41, 2), (48, 2), (44, 2),
            (48, 2), (41, 2), (43, 2), (43, 2),
            (rest, 2), (48, 2),
            (rest, 2), (43, 2),
            (36, 4),
        ]),
        composer: "Ludwig van Beethoven")

    /// The opening of "Für Elise", in A minor. One beat is an eighth note,
    /// three beats in a bar.
    public static let furElise = BuiltInSong(
        id: "fur-elise", title: "Für Elise", beatsPerBar: 3,
        notes: hand(.right, [
            (rest, 2), (76, 0.5), (75, 0.5),
            (76, 0.5), (75, 0.5), (76, 0.5), (71, 0.5), (74, 0.5), (72, 0.5),
            (69, 1), (rest, 0.5), (60, 0.5), (64, 0.5), (69, 0.5),
            (71, 1), (rest, 0.5), (64, 0.5), (68, 0.5), (71, 0.5),
            (72, 1), (rest, 0.5), (64, 0.5), (76, 0.5), (75, 0.5),
            (76, 0.5), (75, 0.5), (76, 0.5), (71, 0.5), (74, 0.5), (72, 0.5),
            (69, 1), (rest, 0.5), (60, 0.5), (64, 0.5), (69, 0.5),
            (71, 1), (rest, 0.5), (64, 0.5), (72, 0.5), (71, 0.5),
            (69, 3),
        ]) + hand(.left, [
            (rest, 3), (rest, 3),
            (45, 0.5), (52, 0.5), (57, 0.5), (rest, 1.5),
            (40, 0.5), (52, 0.5), (56, 0.5), (rest, 1.5),
            (45, 0.5), (52, 0.5), (57, 0.5), (rest, 1.5),
            (rest, 3),
            (45, 0.5), (52, 0.5), (57, 0.5), (rest, 1.5),
            (40, 0.5), (52, 0.5), (56, 0.5), (rest, 1.5),
            (45, 0.5), (52, 0.5), (57, 2),
        ]),
        composer: "Ludwig van Beethoven")

    /// The first half of the Minuet in G from the notebook for Anna
    /// Magdalena Bach, in G major, three beats in a bar.
    public static let minuetInG = BuiltInSong(
        id: "minuet-in-g", title: "Minuet in G", beatsPerBar: 3,
        notes: hand(.right, [
            (74, 1), (67, 0.5), (69, 0.5), (71, 0.5), (72, 0.5),
            (74, 1), (67, 1), (67, 1),
            (76, 1), (72, 0.5), (74, 0.5), (76, 0.5), (78, 0.5),
            (79, 1), (67, 1), (67, 1),
            (72, 1), (74, 0.5), (72, 0.5), (71, 0.5), (69, 0.5),
            (71, 1), (72, 0.5), (71, 0.5), (69, 0.5), (67, 0.5),
            (66, 1), (67, 0.5), (69, 0.5), (71, 0.5), (67, 0.5),
            (69, 3),
            (74, 1), (67, 0.5), (69, 0.5), (71, 0.5), (72, 0.5),
            (74, 1), (67, 1), (67, 1),
            (76, 1), (72, 0.5), (74, 0.5), (76, 0.5), (78, 0.5),
            (79, 1), (67, 1), (67, 1),
            (72, 1), (74, 0.5), (72, 0.5), (71, 0.5), (69, 0.5),
            (71, 1), (72, 0.5), (71, 0.5), (69, 0.5), (67, 0.5),
            (69, 1), (71, 0.5), (69, 0.5), (67, 0.5), (66, 0.5),
            (67, 3),
        ]) + hand(.left, [
            (55, 3), (59, 3), (60, 3), (59, 3),
            (57, 3), (55, 3), (50, 3), (50, 3),
            (55, 3), (59, 3), (60, 3), (59, 3),
            (57, 3), (55, 3), (50, 3), (43, 3),
        ]),
        composer: "Christian Petzold")

    /// Pachelbel's Canon in D major: the same eight bass notes under three
    /// tunes, four beats in a bar.
    public static let canonInD = BuiltInSong(
        id: "canon-in-d", title: "Canon in D", beatsPerBar: 4,
        notes: hand(.right, [
            (78, 2), (76, 2), (74, 2), (73, 2), (71, 2), (69, 2), (71, 2), (73, 2),
            (74, 2), (73, 2), (71, 2), (69, 2), (67, 2), (66, 2), (67, 2), (64, 2),
            (74, 1), (78, 1), (81, 1), (79, 1), (78, 1), (74, 1), (78, 1), (76, 1),
            (74, 1), (71, 1), (74, 1), (69, 1), (67, 1), (71, 1), (69, 1), (67, 1),
            (74, 4),
        ]) + hand(.left, canonBass + canonBass + canonBass + [(50, 4)]),
        composer: "Johann Pachelbel")

    /// The eight bass notes of the canon: D, A, B, F sharp, G, D, G, A.
    private static let canonBass: [(key: UInt8, beats: Double)] = [
        (50, 2), (45, 2), (47, 2), (42, 2), (43, 2), (38, 2), (43, 2), (45, 2),
    ]

    /// The key that marks a rest in `hand`.
    private static let rest: UInt8 = 0

    /// The notes of one hand, one after the other, from (key, beats) pairs.
    /// A pair with key `rest` is a rest.
    static func hand(_ hand: Note.Hand, _ notes: [(key: UInt8, beats: Double)]) -> [Note] {
        var start = 0.0
        var result: [Note] = []
        for note in notes {
            if note.key != rest {
                result.append(Note(key: note.key, start: start, length: note.beats, hand: hand))
            }
            start += note.beats
        }
        return result
    }
}
