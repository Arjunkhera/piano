import XCTest
@testable import PianoCore

final class LevelCheckerTests: XCTestCase {
    private func rules(_ breaches: [Breach]) -> Set<Breach.Rule> {
        Set(breaches.map(\.rule))
    }

    func testAChordAndABlackKeyBreakTheBeginnerRules() {
        let notes = [
            Note(key: 60, start: 0, length: 1, hand: .right),
            Note(key: 64, start: 0, length: 1, hand: .right),
            Note(key: 66, start: 1, length: 0.5, hand: .right),
            Note(key: 72, start: 2, length: 1, hand: .right),
        ]
        let found = rules(LevelChecker.check(notes, level: .beginner, key: MusicKey(tonic: 0, mode: .major)))
        XCTAssertEqual(found, [.tooManyAtOnce, .blackKey, .offGrid, .tooShort, .outsidePosition])
    }

    func testAHardKeyBreaksTheIntermediateRules() {
        let found = LevelChecker.check([], level: .intermediate, key: MusicKey(tonic: 4, mode: .major))
        XCTAssertEqual(rules(found), [.keyTooHard])
    }

    func testAWideChordBreaksTheAdvancedRules() {
        let notes = [
            Note(key: 48, start: 0, length: 1, hand: .left),
            Note(key: 64, start: 0, length: 1, hand: .left),
        ]
        XCTAssertEqual(rules(LevelChecker.check(notes, level: .advanced)), [.tooWide])
    }

    func testANoteThatEndsAsTheNextStartsIsNotHeld() {
        let notes = [
            Note(key: 60, start: 0, length: 1, hand: .right),
            Note(key: 62, start: 1, length: 1, hand: .right),
        ]
        XCTAssertEqual(LevelChecker.check(notes, level: .beginner, key: MusicKey(tonic: 0, mode: .major)), [])
    }

    func testAKeyOffThePianoIsABreach() {
        let notes = [Note(key: 110, start: 0, length: 1, hand: .right)]
        XCTAssertTrue(rules(LevelChecker.check(notes, level: .advanced)).contains(.keyRange))
    }
}
