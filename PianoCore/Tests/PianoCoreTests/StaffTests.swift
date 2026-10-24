import XCTest
@testable import PianoCore

final class StaffTests: XCTestCase {
    func testTrebleStaffLinesAndSpaces() {
        XCTAssertEqual(Staff.step(of: 64, clef: .treble), 0, "E4 sits on the bottom line")
        XCTAssertEqual(Staff.step(of: 65, clef: .treble), 1, "F4 sits in the first space")
        XCTAssertEqual(Staff.step(of: 67, clef: .treble), 2, "G4 sits on the second line")
        XCTAssertEqual(Staff.step(of: 77, clef: .treble), 8, "F5 sits on the top line")
        XCTAssertEqual(Staff.step(of: 62, clef: .treble), -1, "D4 hangs below the staff")
        XCTAssertEqual(Staff.step(of: 60, clef: .treble), -2, "middle C sits on a ledger line")
    }

    func testBassStaffLinesAndSpaces() {
        XCTAssertEqual(Staff.step(of: 43, clef: .bass), 0, "G2 sits on the bottom line")
        XCTAssertEqual(Staff.step(of: 48, clef: .bass), 3, "C3 sits in the second space")
        XCTAssertEqual(Staff.step(of: 57, clef: .bass), 8, "A3 sits on the top line")
        XCTAssertEqual(Staff.step(of: 60, clef: .bass), 10, "middle C sits on a ledger line above")
    }

    func testBlackKeysHaveNoStep() {
        XCTAssertNil(Staff.step(of: 61, clef: .treble))
        XCTAssertNil(Staff.step(of: 54, clef: .bass))
    }

    func testLedgerLines() {
        XCTAssertEqual(Staff.ledgerLines(for: -2), [-2])
        XCTAssertEqual(Staff.ledgerLines(for: -1), [])
        XCTAssertEqual(Staff.ledgerLines(for: -3), [-2])
        XCTAssertEqual(Staff.ledgerLines(for: -4), [-2, -4])
        XCTAssertEqual(Staff.ledgerLines(for: 4), [])
        XCTAssertEqual(Staff.ledgerLines(for: 9), [])
        XCTAssertEqual(Staff.ledgerLines(for: 10), [10])
        XCTAssertEqual(Staff.ledgerLines(for: 13), [10, 12])
    }

    func testClefOfHand() {
        XCTAssertEqual(Clef.of(.right), .treble)
        XCTAssertEqual(Clef.of(.left), .bass)
    }
}
