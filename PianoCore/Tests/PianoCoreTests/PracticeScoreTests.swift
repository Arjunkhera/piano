import XCTest
@testable import PianoCore

final class PracticeScoreTests: XCTestCase {
    private func tip(right: Int, of notes: Int, late: Int = 0, tempo: Int = 60) -> Tip {
        PracticeScore(notes: notes, right: right, wrongKeys: notes - right, late: late, tempo: tempo).tip
    }

    func testFasterAtNinetyPercentRightAndTenPercentLate() {
        XCTAssertEqual(tip(right: 9, of: 10, late: 1).kind, .faster)
        XCTAssertEqual(tip(right: 9, of: 10, late: 1).tempo, 70)
        XCTAssertEqual(tip(right: 20, of: 20, late: 3).kind, .again, "15 percent late is too many")
    }

    func testAgainFromSeventyPercentRight() {
        XCTAssertEqual(tip(right: 8, of: 10).kind, .again)
        XCTAssertEqual(tip(right: 7, of: 10).kind, .again)
        XCTAssertEqual(tip(right: 7, of: 10).tempo, 60)
        XCTAssertEqual(tip(right: 7, of: 10).text, "Play it again at 60 beats per minute.")
    }

    func testSlowerBelowSeventyPercentRight() {
        XCTAssertEqual(tip(right: 6, of: 10), Tip(kind: .slower, tempo: 50, text: "Try it slower, at 50 beats per minute."))
    }

    func testTipTempoStaysInRange() {
        XCTAssertEqual(tip(right: 10, of: 10, tempo: 240).tempo, 240)
        XCTAssertEqual(tip(right: 0, of: 10, tempo: 30).tempo, 30)
    }

    func testSummaryCountsKeys() {
        XCTAssertEqual(PracticeScore(notes: 14, right: 13, wrongKeys: 1, late: 1, tempo: 60).summary,
                       "13 of 14 right. 1 wrong key. 1 late.")
        XCTAssertEqual(PracticeScore(notes: 5, right: 3, wrongKeys: 4, late: 0, tempo: 60).summary,
                       "3 of 5 right. 4 wrong keys. 0 late.")
    }
}
