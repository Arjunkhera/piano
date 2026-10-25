import XCTest
@testable import PianoCore

final class ClassicalSongsTests: XCTestCase {
    func testClassicalPiecesAreInTheSongList() {
        let ids = BuiltInSong.all.map(\.id)
        XCTAssertEqual(Set(ids).count, ids.count, "each song has its own id")
        for song in BuiltInSong.classical {
            XCTAssertTrue(ids.contains(song.id), song.title)
            XCTAssertNotNil(song.composer, song.title)
        }
        XCTAssertEqual(BuiltInSong.classical.map(\.id),
                       ["beethoven-fifth", "fur-elise", "minuet-in-g", "canon-in-d"])
    }

    func testFirstTunesHaveNoComposer() {
        for song in [BuiltInSong.twinkle, .odeToJoy, .cMajorScale] {
            XCTAssertNil(song.composer, song.title)
        }
    }

    func testEachPieceHasBothHandsThatEndTogetherOnABarLine() {
        for song in BuiltInSong.classical {
            let right = song.notes.filter { $0.hand == .right }
            let left = song.notes.filter { $0.hand == .left }
            XCTAssertFalse(right.isEmpty, song.title)
            XCTAssertFalse(left.isEmpty, song.title)
            let rightEnd = right.map { $0.start + $0.length }.max() ?? 0
            let leftEnd = left.map { $0.start + $0.length }.max() ?? 0
            XCTAssertEqual(rightEnd, leftEnd, song.title)
            XCTAssertEqual(rightEnd.truncatingRemainder(dividingBy: Double(song.beatsPerBar)), 0, song.title)
        }
    }

    func testEachHandPlaysOneNoteAtATime() {
        for song in BuiltInSong.classical {
            for hand in [Note.Hand.right, .left] {
                let notes = song.notes.filter { $0.hand == hand }.sorted { $0.start < $1.start }
                for (a, b) in zip(notes, notes.dropFirst()) {
                    XCTAssertLessThanOrEqual(a.start + a.length, b.start, "\(song.title), \(hand)")
                }
            }
        }
    }

    func testTheKeyFinderFindsTheKeyOfEachPiece() {
        let expected: [String: MusicKey] = [
            "beethoven-fifth": MusicKey(tonic: 0, mode: .minor),
            "fur-elise": MusicKey(tonic: 9, mode: .minor),
            "minuet-in-g": MusicKey(tonic: 7, mode: .major),
            "canon-in-d": MusicKey(tonic: 2, mode: .major),
        ]
        for song in BuiltInSong.classical {
            XCTAssertEqual(MusicKey.find(in: song.notes), expected[song.id], song.title)
        }
    }

    func testFifthSymphonyStartsWithTheFourNoteCall() {
        let right = BuiltInSong.beethovenFifth.notes.filter { $0.hand == .right }
        XCTAssertEqual(right.prefix(4).map(\.key), [67, 67, 67, 63])
        XCTAssertEqual(right.first?.start, 0.5, "the call starts after an eighth rest")
        XCTAssertEqual(right[3].length, 4)
    }

    func testRestsMoveTheNextNoteOnAndAddNoNote() {
        let notes = BuiltInSong.hand(.left, [(0, 1), (60, 1), (0, 2), (62, 1)])
        XCTAssertEqual(notes, [
            Note(key: 60, start: 1, length: 1, hand: .left),
            Note(key: 62, start: 4, length: 1, hand: .left),
        ])
    }

    func testEachLevelOfEachPieceHasEnoughToPractise() {
        for song in BuiltInSong.classical {
            for lesson in LessonMaker.makeAll(from: song.notes, beatsPerBar: song.beatsPerBar) {
                XCTAssertEqual(LevelChecker.check(lesson), [], "\(song.title), \(lesson.level)")
                XCTAssertGreaterThanOrEqual(lesson.notes.count, 16, "\(song.title), \(lesson.level)")
                XCTAssertGreaterThanOrEqual(lesson.parts().count, 2, "\(song.title), \(lesson.level)")
            }
            let advanced = LessonMaker.make(.advanced, from: song.notes, beatsPerBar: song.beatsPerBar)
            XCTAssertTrue(advanced.notes.contains { $0.hand == .left }, "\(song.title) keeps its left hand")
        }
    }
}
