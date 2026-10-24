import XCTest
@testable import PianoCore

final class WaitModeTests: XCTestCase {
    /// The first line of "Twinkle, Twinkle, Little Star" at the beginner level.
    private func twinkleBeginner() -> [Note] {
        let firstLine = Array(BuiltInSong.twinkle.notes.prefix(14))
        return LessonMaker.make(.beginner, from: firstLine).notes
    }

    /// Presses each key of each step that is left, on time, and returns the
    /// time of the last press.
    @discardableResult
    private func playOnTime(_ wait: inout WaitMode, startingAt time: Double) -> Double {
        var time = time
        while let step = wait.current {
            for key in step.keys.sorted() { wait.press(key, at: time) }
            if let next = wait.current { time += (next.beat - step.beat) * wait.secondsPerBeat }
        }
        return time
    }

    // MARK: Steps

    func testNotesOnOneBeatMakeOneStep() {
        let notes = [
            Note(key: 48, start: 0, length: 4, hand: .left),
            Note(key: 64, start: 0, length: 1, hand: .right),
            Note(key: 62, start: 1, length: 1, hand: .right),
        ]
        let steps = PracticeStep.steps(from: notes)
        XCTAssertEqual(steps.map(\.beat), [0, 1])
        XCTAssertEqual(steps.map(\.keys), [[48, 64], [62]])
    }

    func testHandsPickTheNotes() {
        let notes = [
            Note(key: 48, start: 0, length: 4, hand: .left),
            Note(key: 64, start: 0, length: 1, hand: .right),
        ]
        XCTAssertEqual(PracticeStep.steps(from: notes, hands: .right).map(\.keys), [[64]])
        XCTAssertEqual(PracticeStep.steps(from: notes, hands: .left).map(\.keys), [[48]])
        XCTAssertEqual(PracticeStep.steps(from: notes, hands: .both).map(\.keys), [[48, 64]])
    }

    // MARK: US-1

    func testWrongKeyThenRightKeyGivesTheScoreOfUS1() {
        let notes = twinkleBeginner()
        XCTAssertEqual(notes.map(\.key), [60, 60, 67, 67, 57, 57, 67, 65, 65, 64, 64, 62, 62, 60])
        var wait = WaitMode(notes: notes, hands: .both, tempo: 60)
        XCTAssertEqual(wait.steps.count, 14)
        XCTAssertEqual(wait.waitingFor, [60])

        XCTAssertEqual(wait.press(62, at: 0), .wrong)
        XCTAssertEqual(wait.stepIndex, 0, "a wrong key keeps the step")
        XCTAssertEqual(wait.waitingFor, [60])
        XCTAssertEqual(wait.press(60, at: 0.5), .right)
        XCTAssertEqual(wait.stepIndex, 1)

        playOnTime(&wait, startingAt: 1.5)
        XCTAssertTrue(wait.isDone)
        let score = wait.score
        XCTAssertEqual(score, PracticeScore(notes: 14, right: 13, wrongKeys: 1, late: 0, tempo: 60))
        XCTAssertEqual(score.summary, "13 of 14 right. 1 wrong key. 0 late.")
        XCTAssertEqual(score.tip, Tip(kind: .faster, tempo: 70, text: "Well done. Try it at 70 beats per minute."))
    }

    // MARK: US-2

    func testChordNeedsEachKeyInAnyOrder() {
        let notes = [
            Note(key: 48, start: 0, length: 4, hand: .left),
            Note(key: 55, start: 0, length: 4, hand: .left),
            Note(key: 60, start: 4, length: 1, hand: .right),
        ]
        var wait = WaitMode(notes: notes, tempo: 60)
        XCTAssertEqual(wait.press(55, at: 0), .right)
        XCTAssertEqual(wait.stepIndex, 0)
        XCTAssertEqual(wait.waitingFor, [48])
        XCTAssertEqual(wait.press(48, at: 0.2), .right)
        XCTAssertEqual(wait.stepIndex, 1)
        XCTAssertEqual(wait.waitingFor, [60])
    }

    // MARK: US-3

    func testRightKeyAfterHalfABeatIsLate() {
        let notes = [
            Note(key: 60, start: 0, length: 1, hand: .right),
            Note(key: 62, start: 1, length: 1, hand: .right),
        ]
        var late = WaitMode(notes: notes, tempo: 60)
        late.press(60, at: 10.0)
        XCTAssertEqual(late.press(62, at: 11.8), .late)
        XCTAssertEqual(late.score.late, 1)
        XCTAssertEqual(late.score.right, 2, "a late note is still right")

        var onTime = WaitMode(notes: notes, tempo: 60)
        onTime.press(60, at: 10.0)
        XCTAssertEqual(onTime.press(62, at: 11.4), .right)
    }

    func testTheFirstStepIsNeverLate() {
        var wait = WaitMode(notes: [Note(key: 60, start: 2, length: 1, hand: .right)], tempo: 60)
        XCTAssertEqual(wait.press(60, at: 500), .right)
    }

    func testLateLimitFollowsTheTempo() {
        let notes = [
            Note(key: 60, start: 0, length: 2, hand: .right),
            Note(key: 62, start: 2, length: 1, hand: .right),
        ]
        // At 120 beats per minute a beat is 0.5 s: due at 1.0 s, limit 1.25 s.
        var wait = WaitMode(notes: notes, tempo: 120)
        wait.press(60, at: 0)
        XCTAssertEqual(wait.press(62, at: 1.3), .late)
    }

    // MARK: Edges

    func testRepeatOfAPressedKeyGetsNoMark() {
        let notes = [
            Note(key: 60, start: 0, length: 1, hand: .right),
            Note(key: 64, start: 0, length: 1, hand: .right),
        ]
        var wait = WaitMode(notes: notes, tempo: 60)
        wait.press(60, at: 0)
        XCTAssertNil(wait.press(60, at: 0.1))
        XCTAssertEqual(wait.presses.count, 1)
        XCTAssertEqual(wait.score.wrongKeys, 0)
    }

    func testPressAfterTheEndGetsNoMark() {
        var wait = WaitMode(notes: [Note(key: 60, start: 0, length: 1, hand: .right)], tempo: 60)
        wait.press(60, at: 0)
        XCTAssertTrue(wait.isDone)
        XCTAssertNil(wait.press(62, at: 1))
        XCTAssertEqual(wait.presses.count, 1)
    }

    func testTwoWrongKeysOnOneNoteCountOnce() {
        var wait = WaitMode(notes: [Note(key: 60, start: 0, length: 1, hand: .right)], tempo: 60)
        wait.press(61, at: 0)
        wait.press(62, at: 0.1)
        wait.press(60, at: 0.2)
        XCTAssertEqual(wait.score, PracticeScore(notes: 1, right: 0, wrongKeys: 2, late: 0, tempo: 60))
    }

    func testEmptyPartIsDoneAtOnce() {
        let wait = WaitMode(notes: [Note(key: 48, start: 0, length: 1, hand: .left)], hands: .right, tempo: 60)
        XCTAssertTrue(wait.isDone)
        XCTAssertEqual(wait.score.summary, "No notes to play.")
        XCTAssertEqual(wait.score.tip.kind, .again)
    }

    func testTempoStaysInRange() {
        XCTAssertEqual(WaitMode(steps: [], tempo: 5).tempo, 30)
        XCTAssertEqual(WaitMode(steps: [], tempo: 900).tempo, 240)
    }

    func testWaitModeIsTheSameEachTime() {
        let notes = LessonMaker.make(.intermediate, from: BuiltInSong.odeToJoy.notes).notes
        var first = WaitMode(notes: notes, tempo: 80)
        var second = WaitMode(notes: notes, tempo: 80)
        let end1 = playOnTime(&first, startingAt: 0)
        let end2 = playOnTime(&second, startingAt: 0)
        XCTAssertEqual(end1, end2)
        XCTAssertEqual(first.presses, second.presses)
        XCTAssertEqual(first.score.right, first.score.notes)
        XCTAssertEqual(first.score.late, 0)
    }
}
