import XCTest
@testable import PianoCore

final class LessonMakerTests: XCTestCase {
    /// "Twinkle, Twinkle, Little Star", first line, right hand, moved up by `shift` keys.
    private func twinkle(shift: Int = 0) -> [Note] {
        let keys: [Int] = [60, 60, 67, 67, 69, 69, 67, 65, 65, 64, 64, 62, 62, 60]
        let lengths: [Double] = [1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 2]
        var start = 0.0
        return zip(keys, lengths).map { key, length in
            defer { start += length }
            return Note(key: UInt8(key + shift), start: start, length: length, hand: .right)
        }
    }

    // MARK: Beginner

    func testBeginnerMovesTwinkleFromDToMiddleCPosition() {
        let lesson = LessonMaker.make(.beginner, from: twinkle(shift: 2))
        XCTAssertEqual(lesson.shift, -2)
        XCTAssertEqual(lesson.key, MusicKey(tonic: 0, mode: .major))
        XCTAssertEqual(lesson.notes.map(\.key), [60, 60, 67, 67, 57, 57, 67, 65, 65, 64, 64, 62, 62, 60])
        XCTAssertEqual(lesson.notes.map(\.start), [0, 1, 2, 3, 4, 5, 6, 8, 9, 10, 11, 12, 13, 14])
        XCTAssertEqual(lesson.notes.map(\.length), [1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 2])
        XCTAssertEqual(lesson.notes.map(\.finger), [1, 1, 5, 5, 3, 3, 5, 4, 4, 3, 3, 2, 2, 1])
        // A goes to the left hand; the rest stay in the right hand.
        XCTAssertEqual(lesson.notes.filter { $0.hand == .left }.map(\.key), [57, 57])
        XCTAssertEqual(LevelChecker.check(lesson), [])
    }

    func testBeginnerKeepsTheTopKeyOfAChord() {
        let chord = [60, 64, 67].map { Note(key: $0, start: 0, length: 2, hand: .right) }
        let lesson = LessonMaker.make(.beginner, from: chord)
        XCTAssertEqual(lesson.notes, [Note(key: 67, start: 0, length: 2, hand: .right, finger: 5)])
    }

    func testBeginnerSnapsOffBeatNotesToTheBeat() {
        let notes = [
            Note(key: 60, start: 0, length: 1.5, hand: .right),
            Note(key: 62, start: 1.5, length: 1.5, hand: .right),
            Note(key: 64, start: 3, length: 1, hand: .right),
        ]
        let lesson = LessonMaker.make(.beginner, from: notes)
        XCTAssertEqual(lesson.notes.map(\.start), [0, 2, 3])
        XCTAssertEqual(lesson.notes.map(\.length), [2, 1, 1])
    }

    func testBeginnerNotesEndAtTheBarLine() {
        let notes = [Note(key: 60, start: 2, length: 4, hand: .right)]
        let lesson = LessonMaker.make(.beginner, from: notes, beatsPerBar: 3)
        XCTAssertEqual(lesson.notes.map(\.length), [1])
    }

    // MARK: Intermediate

    func testIntermediateMovesEMajorToEFlatMajor() {
        let lesson = LessonMaker.make(.intermediate, from: twinkle(shift: 4))
        XCTAssertEqual(lesson.shift, -1)
        XCTAssertEqual(lesson.key.name, "Eb major")
        XCTAssertEqual(LevelChecker.check(lesson), [])
    }

    func testIntermediateKeepsAnEasyKey() {
        XCTAssertEqual(LessonMaker.make(.intermediate, from: twinkle(shift: 2)).shift, 0)
    }

    func testIntermediateLeftHandPlaysRootAndFifth() {
        let melody = [
            Note(key: 64, start: 0, length: 2, hand: .right),
            Note(key: 67, start: 2, length: 1, hand: .right),
            Note(key: 72, start: 3, length: 1, hand: .right),
        ]
        let lesson = LessonMaker.make(.intermediate, from: melody)
        XCTAssertEqual(lesson.notes.filter { $0.hand == .left }, [
            Note(key: 48, start: 0, length: 4, hand: .left),
            Note(key: 55, start: 0, length: 4, hand: .left),
        ])
        XCTAssertEqual(lesson.notes.filter { $0.hand == .right }.map(\.key), [64, 67, 72])
    }

    func testIntermediateRightHandKeepsTheTopTwoKeys() {
        let chord = [60, 64, 67, 72].map { Note(key: $0, start: 0, length: 4, hand: .right) }
        let lesson = LessonMaker.make(.intermediate, from: chord)
        XCTAssertEqual(lesson.notes.filter { $0.hand == .right }.map(\.key), [67, 72])
    }

    func testIntermediateSnapsToTheEighthNote() {
        let notes = [Note(key: 60, start: 0.3, length: 0.6, hand: .right)]
        let lesson = LessonMaker.make(.intermediate, from: notes)
        let right = lesson.notes.filter { $0.hand == .right }
        XCTAssertEqual(right.map(\.start), [0.5])
        XCTAssertEqual(right.map(\.length), [0.5])
    }

    // MARK: Advanced

    func testAdvancedKeepsTheSongAndDropsShortOrnaments() {
        let notes = [
            Note(key: 66, start: 0, length: 0.0625, hand: .right),
            Note(key: 67, start: 0.0625, length: 0.9375, hand: .right, finger: 3),
            Note(key: 43, start: 0, length: 1, hand: .left),
        ]
        let lesson = LessonMaker.make(.advanced, from: notes)
        XCTAssertEqual(lesson.shift, 0)
        XCTAssertEqual(lesson.notes, [notes[2], notes[1]])
    }

    func testAdvancedLimitsAHandToANinth() {
        let notes = [
            Note(key: 60, start: 0, length: 1, hand: .right),
            Note(key: 76, start: 0, length: 1, hand: .right),
        ]
        XCTAssertEqual(LessonMaker.make(.advanced, from: notes).notes.map(\.key), [76])
    }

    func testHeldNoteEndsWhenItBreaksTheLimit() {
        let notes = [
            Note(key: 84, start: 0, length: 4, hand: .right),
            Note(key: 60, start: 1, length: 1, hand: .right),
        ]
        let lesson = LessonMaker.make(.advanced, from: notes)
        XCTAssertEqual(lesson.notes, [
            Note(key: 84, start: 0, length: 1, hand: .right),
            Note(key: 60, start: 1, length: 1, hand: .right),
        ])
    }

    // MARK: Every level

    func testBadNotesAreDropped() {
        let notes = [
            Note(key: 10, start: 0, length: 1, hand: .right),
            Note(key: 60, start: -1, length: 1, hand: .right),
            Note(key: 62, start: 0, length: 0, hand: .right),
        ]
        for lesson in LessonMaker.makeAll(from: notes) {
            XCTAssertEqual(lesson.notes, [], "\(lesson.level)")
        }
    }

    func testEmptyScoreGivesEmptyLessons() {
        let lessons = LessonMaker.makeAll(from: [])
        XCTAssertEqual(lessons.map(\.level), [.beginner, .intermediate, .advanced])
        XCTAssertTrue(lessons.allSatisfy { $0.notes.isEmpty && $0.shift == 0 })
    }

    func testLessonRoundTripsThroughJSON() throws {
        let lesson = LessonMaker.make(.beginner, from: twinkle())
        let data = try JSONEncoder().encode(lesson)
        XCTAssertEqual(try JSONDecoder().decode(Lesson.self, from: data), lesson)
    }

    /// 600 made-up scores, at each level and with four bar lengths. Every
    /// lesson must pass the checker, and the same score must give the same
    /// lesson.
    func testEveryLessonPassesItsChecker() {
        var random = SeededRandom(seed: 7)
        for _ in 0..<600 {
            let score = random.score()
            let beatsPerBar = [2, 3, 4, 6][Int(random.next() % 4)]
            for level in Level.allCases {
                let lesson = LessonMaker.make(level, from: score, beatsPerBar: beatsPerBar)
                let breaches = LevelChecker.check(lesson)
                XCTAssertEqual(breaches, [], "\(level): \(breaches.prefix(3).map(\.detail))")
                XCTAssertEqual(LessonMaker.make(level, from: score, beatsPerBar: beatsPerBar), lesson)
                if !breaches.isEmpty { return }
            }
        }
    }
}

/// A small fixed random source, so the test gives the same scores each run.
struct SeededRandom {
    private var state: UInt64

    init(seed: UInt64) { state = seed }

    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state >> 33
    }

    mutating func score() -> [Note] {
        (0..<Int(next() % 60)).map { _ in
            Note(key: UInt8(15 + next() % 98),
                 start: Double(Int(next() % 400) - 10) / 12,
                 length: Double(next() % 49) / 12,
                 hand: next() % 2 == 0 ? .right : .left)
        }
    }
}
