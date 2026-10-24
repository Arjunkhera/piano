import XCTest
@testable import PianoCore

final class MIDIParserTests: XCTestCase {
    func testKeyOn() {
        var parser = MIDIParser()
        XCTAssertEqual(parser.parse([0x90, 0x3C, 0x64]), [KeyEvent(kind: .keyOn, key: 60, force: 100)])
    }

    func testKeyOff() {
        var parser = MIDIParser()
        XCTAssertEqual(parser.parse([0x80, 0x3C, 0x40]), [KeyEvent(kind: .keyOff, key: 60, force: 64)])
    }

    func testKeyOnWithForceZeroIsKeyOff() {
        var parser = MIDIParser()
        XCTAssertEqual(parser.parse([0x90, 0x3C, 0x00]), [KeyEvent(kind: .keyOff, key: 60, force: 0)])
    }

    func testRunningStatus() {
        var parser = MIDIParser()
        let events = parser.parse([0x90, 0x3C, 0x50, 0x40, 0x50, 0x43, 0x50])
        XCTAssertEqual(events.map(\.key), [60, 64, 67])
        XCTAssertEqual(events.map(\.kind), [.keyOn, .keyOn, .keyOn])
    }

    func testRunningStatusAcrossPackets() {
        var parser = MIDIParser()
        XCTAssertEqual(parser.parse([0x90, 0x3C]), [])
        XCTAssertEqual(parser.parse([0x50, 0x40, 0x00]).map(\.kind), [.keyOn, .keyOff])
    }

    func testChordInOnePacket() {
        var parser = MIDIParser()
        let events = parser.parse([0x90, 0x3C, 0x50, 0x90, 0x40, 0x50, 0x90, 0x43, 0x50])
        XCTAssertEqual(events.map(\.key), [60, 64, 67])
    }

    func testPedal() {
        var parser = MIDIParser()
        XCTAssertEqual(parser.parse([0xB0, 0x40, 0x7F]), [KeyEvent(kind: .pedal, key: 0, force: 127)])
    }

    func testOtherControlIsDropped() {
        var parser = MIDIParser()
        XCTAssertEqual(parser.parse([0xB0, 0x07, 0x64]), [])
    }

    func testRealTimeBytesAreDropped() {
        var parser = MIDIParser()
        XCTAssertEqual(parser.parse([0xFE, 0x90, 0xF8, 0x3C, 0x64]).map(\.key), [60])
    }

    func testKeysOutsideThePianoAreDropped() {
        var parser = MIDIParser()
        XCTAssertEqual(parser.parse([0x90, 20, 0x64, 0x90, 109, 0x64, 0x90, 21, 0x64]).map(\.key), [21])
    }

    func testChannelIsKept() {
        var parser = MIDIParser()
        XCTAssertEqual(parser.parse([0x93, 0x3C, 0x64]).first?.channel, 3)
    }

    func testResetClearsRunningStatus() {
        var parser = MIDIParser()
        _ = parser.parse([0x90, 0x3C, 0x64])
        parser.reset()
        XCTAssertEqual(parser.parse([0x40, 0x64]), [])
    }
}
