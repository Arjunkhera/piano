import XCTest
@testable import ListenOptions

final class ListenOptionsTests: XCTestCase {
    func testRecordWithEveryOption() throws {
        let options = try ListenOptions.parse([
            "record", "Let It Be", "--seconds", "240", "--app", "Safari",
            "--out", "/tmp/songs", "--keep-audio", "--device", "mps",
        ])
        var expected = ListenOptions(command: .record(name: "Let It Be"))
        expected.seconds = 240
        expected.app = "Safari"
        expected.outFolder = "/tmp/songs"
        expected.keepAudio = true
        expected.device = "mps"
        XCTAssertEqual(options, expected)
    }

    func testTranscribeTakesTheNameFromTheFile() throws {
        let options = try ListenOptions.parse(["transcribe", "/Users/me/cover.m4a"])
        XCTAssertEqual(options.command, .transcribe(audio: "/Users/me/cover.m4a", name: "cover"))
    }

    func testNoWordsIsHelp() throws {
        XCTAssertEqual(try ListenOptions.parse([]).command, .help)
        XCTAssertEqual(try ListenOptions.parse(["record", "x", "--help"]).command, .help)
    }

    func testMistakesAreRefused() {
        XCTAssertThrowsError(try ListenOptions.parse(["record"]))
        XCTAssertThrowsError(try ListenOptions.parse(["record", "a", "b"]))
        XCTAssertThrowsError(try ListenOptions.parse(["record", "a", "--seconds", "zero"]))
        XCTAssertThrowsError(try ListenOptions.parse(["record", "a", "--seconds"]))
        XCTAssertThrowsError(try ListenOptions.parse(["record", "a", "--device", "cuda"]))
        XCTAssertThrowsError(try ListenOptions.parse(["record", "a", "--upload"]))
        XCTAssertThrowsError(try ListenOptions.parse(["play"]))
    }

    func testFileNameIsMadeSafe() throws {
        XCTAssertEqual(try ListenOptions.fileName("AC/DC: Back"), "AC-DC- Back")
        XCTAssertEqual(try ListenOptions.fileName("..hidden"), "hidden")
        XCTAssertThrowsError(try ListenOptions.fileName("  "))
    }
}
