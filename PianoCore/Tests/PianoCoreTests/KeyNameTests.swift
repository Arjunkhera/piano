import Foundation
import XCTest
@testable import PianoCore

final class KeyNameTests: XCTestCase {
    func testNames() {
        XCTAssertEqual(KeyName.name(of: 60), "C4")
        XCTAssertEqual(KeyName.name(of: 21), "A0")
        XCTAssertEqual(KeyName.name(of: 108), "C8")
        XCTAssertEqual(KeyName.name(of: 61), "C#4")
    }

    func testMiddleCLabel() {
        XCTAssertEqual(KeyName.label(of: 60), "C4, middle C")
        XCTAssertEqual(KeyName.label(of: 62), "D4")
    }

    func testBlackKeys() {
        XCTAssertTrue(KeyName.isBlack(61))
        XCTAssertFalse(KeyName.isBlack(60))
        XCTAssertEqual(pianoKeys.filter { KeyName.isBlack($0) }.count, 36)
    }

    func testNoteRoundTripsThroughJSON() throws {
        let note = Note(key: 60, start: 0, length: 1, hand: .right, finger: 1)
        let data = try JSONEncoder().encode(note)
        XCTAssertEqual(try JSONDecoder().decode(Note.self, from: data), note)
    }
}
