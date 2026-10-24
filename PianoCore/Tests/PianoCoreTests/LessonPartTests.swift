import XCTest
@testable import PianoCore

final class LessonPartTests: XCTestCase {
    func testTwinkleHasThreePartsOfFourBars() {
        let lesson = LessonMaker.make(.beginner, from: BuiltInSong.twinkle.notes)
        let parts = lesson.parts()
        XCTAssertEqual(parts.map(\.number), [1, 2, 3])
        XCTAssertEqual(parts.map(\.firstBar), [1, 5, 9])
        XCTAssertEqual(parts.map(\.notes.count), [14, 14, 14])
        XCTAssertEqual(parts.flatMap(\.notes), lesson.notes)
    }

    func testNoteAtTheBarLineStartsTheNextPart() {
        let lesson = Lesson(level: .advanced, notes: [
            Note(key: 60, start: 15, length: 2, hand: .right),
            Note(key: 62, start: 16, length: 1, hand: .right),
        ], key: MusicKey(tonic: 0, mode: .major), shift: 0, beatsPerBar: 4)
        let parts = lesson.parts(barsEach: 4)
        XCTAssertEqual(parts.map { $0.notes.map(\.key) }, [[60], [62]])
    }

    func testShortSongHasOnePart() {
        let lesson = LessonMaker.make(.advanced, from: [Note(key: 60, start: 0, length: 1, hand: .right)])
        XCTAssertEqual(lesson.parts().count, 1)
    }

    func testEmptyLessonHasNoParts() {
        XCTAssertEqual(LessonMaker.make(.beginner, from: []).parts(), [])
    }

    func testRestKeepsThePartNumbers() {
        let lesson = Lesson(level: .advanced, notes: [
            Note(key: 60, start: 0, length: 1, hand: .right),
            Note(key: 62, start: 40, length: 1, hand: .right),
        ], key: MusicKey(tonic: 0, mode: .major), shift: 0, beatsPerBar: 4)
        XCTAssertEqual(lesson.parts().map(\.notes.count), [1, 0, 1])
    }

    func testBuiltInSongsMakeCleanLessonsAtEachLevel() {
        for song in BuiltInSong.all {
            for lesson in LessonMaker.makeAll(from: song.notes, beatsPerBar: song.beatsPerBar) {
                XCTAssertEqual(LevelChecker.check(lesson), [], "\(song.title), \(lesson.level)")
                XCTAssertFalse(lesson.notes.isEmpty, "\(song.title), \(lesson.level)")
            }
        }
    }
}
