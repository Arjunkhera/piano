import XCTest
@testable import PianoCore

final class BasicsCourseTests: XCTestCase {
    private var exercises: [BasicsExercise] { BasicsCourse.lessons.flatMap(\.exercises) }

    /// Presses each key of each step on time, and returns the score.
    private func playOnTime(_ exercise: BasicsExercise, wrongKeyOnSteps wrongSteps: Set<Int> = [],
                            lateOnSteps lateSteps: Set<Int> = []) -> PracticeScore {
        var wait = exercise.waitMode()
        var time = 0.0
        while let step = wait.current {
            let index = wait.stepIndex
            if wrongSteps.contains(index) {
                // A key that is in no exercise.
                wait.press(21, at: time)
            }
            let pressAt = lateSteps.contains(index) ? time + wait.secondsPerBeat : time
            for key in step.keys.sorted() { wait.press(key, at: pressAt) }
            time = pressAt
            if let next = wait.current { time += (next.beat - step.beat) * wait.secondsPerBeat }
        }
        return wait.score
    }

    // MARK: The course

    func testCourseHasSevenLessonsInOrder() {
        XCTAssertEqual(BasicsCourse.lessons.map(\.number), Array(1...7))
        XCTAssertEqual(BasicsCourse.lessons.first?.title, "Find middle C")
        for lesson in BasicsCourse.lessons {
            XCTAssertFalse(lesson.teach.isEmpty, "lesson \(lesson.number) teaches nothing")
            XCTAssertFalse(lesson.exercises.isEmpty, "lesson \(lesson.number) has no exercise")
        }
    }

    func testExerciseIdsAreUniqueAndNameTheirLesson() {
        XCTAssertEqual(Set(exercises.map(\.id)).count, exercises.count)
        for lesson in BasicsCourse.lessons {
            for (index, exercise) in lesson.exercises.enumerated() {
                XCTAssertEqual(exercise.id, "\(lesson.number).\(index + 1)")
            }
        }
    }

    func testEveryExerciseHasNotesOnThePiano() {
        for exercise in exercises {
            XCTAssertFalse(exercise.practiceNotes.isEmpty, exercise.id)
            for note in exercise.notes {
                XCTAssertTrue(pianoKeys.contains(note.key), "\(exercise.id): key \(note.key)")
                XCTAssertGreaterThan(note.length, 0, exercise.id)
            }
        }
    }

    func testFingersAreOneToFiveAndFollowTheKeys() {
        for exercise in exercises {
            for hand in [Note.Hand.right, .left] {
                let fingered = exercise.notes.filter { $0.hand == hand && $0.finger != nil }
                var fingerOfKey: [UInt8: Int] = [:]
                for note in fingered {
                    let finger = note.finger!
                    XCTAssertTrue((1...5).contains(finger), "\(exercise.id): finger \(finger)")
                    if let earlier = fingerOfKey[note.key] {
                        XCTAssertEqual(earlier, finger, "\(exercise.id): \(KeyName.name(of: note.key)) gets two fingers")
                    }
                    fingerOfKey[note.key] = finger
                }
                // In a five-finger position, a higher key gets a higher finger
                // in the right hand and a lower finger in the left hand.
                let byKey = fingerOfKey.sorted { $0.key < $1.key }.map(\.value)
                let expected = hand == .right ? byKey.sorted() : byKey.sorted(by: >)
                XCTAssertEqual(byKey, expected, "\(exercise.id): fingers out of order")
            }
        }
    }

    func testStaffExercisesUseWhiteKeysOnly() {
        for exercise in exercises where exercise.hint == .staff {
            for note in exercise.practiceNotes {
                XCTAssertNotNil(Staff.step(of: note.key, clef: .of(note.hand)), "\(exercise.id): \(note.key)")
            }
        }
    }

    func testFirstLessonsAreUntimedAndLaterOnesAreTimed() {
        for lesson in BasicsCourse.lessons {
            for exercise in lesson.exercises where lesson.number <= 4 || lesson.number == 6 {
                XCTAssertFalse(exercise.timed, exercise.id)
            }
            for exercise in lesson.exercises where lesson.number == 5 || lesson.number == 7 {
                XCTAssertTrue(exercise.timed, exercise.id)
            }
        }
    }

    func testTunesFillWholeBars() {
        XCTAssertEqual(BasicsCourse.mary.reduce(0) { $0 + $1.length }, 32)
        let hotCrossBuns = BasicsCourse.beats.exercises[0].notes
        XCTAssertEqual(hotCrossBuns.reduce(0) { $0 + $1.length }, 20)
        let left = BasicsCourse.maryBothHands.filter { $0.hand == .left }
        XCTAssertEqual(left.map(\.start), [0, 4, 8, 12, 16, 20, 24, 28])
        XCTAssertEqual(left.map { KeyName.name(of: $0.key) }, ["C3", "C3", "G3", "C3", "C3", "C3", "G3", "C3"])
    }

    func testBothHandsStepsJoinTheTwoHands() {
        let wait = BasicsCourse.bothHands.exercises[1].waitMode()
        XCTAssertEqual(wait.steps.first?.keys, [48, 64], "C3 and E4 on beat 1")
        let leftOnly = BasicsCourse.bothHands.exercises[0].waitMode()
        XCTAssertEqual(leftOnly.steps.count, 8)
    }

    func testKeyNames() {
        XCTAssertEqual(BasicsCourse.key("C4"), 60)
        XCTAssertEqual(BasicsCourse.key("C#3"), 49)
        XCTAssertEqual(BasicsCourse.key("C1"), 24)
        XCTAssertEqual(BasicsCourse.key("C8"), 108)
        XCTAssertEqual(BasicsCourse.key("G3"), 55)
    }

    // MARK: Pass rule

    func testEveryExercisePassesWhenPlayedRightAndOnTime() {
        for exercise in exercises {
            let score = playOnTime(exercise)
            XCTAssertEqual(score.right, score.notes, exercise.id)
            XCTAssertTrue(exercise.passes(score), exercise.id)
        }
    }

    func testPassNeedsNinetyPercentRight() {
        let exercise = BasicsCourse.rightHand.exercises[1]  // 9 notes
        XCTAssertFalse(exercise.passes(playOnTime(exercise, wrongKeyOnSteps: [3])), "8 of 9 is 89 percent")
        let twenty = BasicsCourse.beats.exercises[1]  // 26 notes
        XCTAssertTrue(twenty.passes(playOnTime(twenty, wrongKeyOnSteps: [3, 9])), "24 of 26 is 92 percent")
        XCTAssertFalse(twenty.passes(playOnTime(twenty, wrongKeyOnSteps: [3, 9, 15])), "23 of 26 is 88 percent")
    }

    func testLateKeysCountOnlyInTimedExercises() {
        let untimed = BasicsCourse.rightHand.exercises[1]
        let allLate = Set(1..<untimed.waitMode().steps.count)
        XCTAssertTrue(untimed.passes(playOnTime(untimed, lateOnSteps: allLate)))

        let timed = BasicsCourse.beats.exercises[1]  // 26 notes
        XCTAssertTrue(timed.passes(playOnTime(timed, lateOnSteps: [2, 5])), "2 of 26 late")
        XCTAssertFalse(timed.passes(playOnTime(timed, lateOnSteps: [2, 5, 8])), "3 of 26 late")
    }

    func testEmptyScoreNeverPasses() {
        let exercise = BasicsCourse.findMiddleC.exercises[0]
        XCTAssertFalse(exercise.passes(PracticeScore(notes: 0, right: 0, wrongKeys: 0, late: 0, tempo: 60)))
    }

    // MARK: Progress and the gate

    func testOnlyTheFirstLessonIsOpenAtTheStart() {
        let progress = BasicsProgress()
        XCTAssertEqual(BasicsCourse.lessons.filter { progress.isOpen($0) }.map(\.number), [1])
        XCTAssertEqual(progress.nextLesson()?.number, 1)
    }

    func testPassingEachExerciseOpensTheNextLesson() {
        var progress = BasicsProgress()
        let first = BasicsCourse.findMiddleC
        for exercise in first.exercises.dropLast() {
            XCTAssertTrue(progress.record(playOnTime(exercise), for: exercise))
        }
        XCTAssertFalse(progress.isOpen(BasicsCourse.rightHand), "one exercise is left")
        let last = first.exercises.last!
        progress.record(playOnTime(last), for: last)
        XCTAssertTrue(progress.isDone(first))
        XCTAssertTrue(progress.isOpen(BasicsCourse.rightHand))
        XCTAssertFalse(progress.isOpen(BasicsCourse.leftHand))
        XCTAssertEqual(progress.nextLesson()?.number, 2)
    }

    func testAFailedTryKeepsAnEarlierPass() {
        var progress = BasicsProgress()
        let exercise = BasicsCourse.findMiddleC.exercises[2]
        progress.record(playOnTime(exercise), for: exercise)
        let failed = playOnTime(exercise, wrongKeyOnSteps: [0, 1, 2])
        XCTAssertFalse(progress.record(failed, for: exercise))
        XCTAssertTrue(progress.hasPassed(exercise))
    }

    func testCourseDoneHasNoNextLesson() {
        let progress = BasicsProgress(passed: Set(exercises.map(\.id)))
        XCTAssertNil(progress.nextLesson())
        XCTAssertTrue(BasicsCourse.lessons.allSatisfy { progress.isOpen($0) })
    }

    func testProgressSurvivesASaveAndALoad() throws {
        let progress = BasicsProgress(passed: ["1.1", "1.2"])
        let data = try JSONEncoder().encode(progress)
        XCTAssertEqual(try JSONDecoder().decode(BasicsProgress.self, from: data), progress)
    }
}
