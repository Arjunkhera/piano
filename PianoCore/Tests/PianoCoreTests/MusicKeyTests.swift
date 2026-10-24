import XCTest
@testable import PianoCore

final class MusicKeyTests: XCTestCase {
    private func scale(from tonic: UInt8) -> [Note] {
        [0, 2, 4, 5, 7, 9, 11, 12].enumerated().map { index, step in
            Note(key: tonic + UInt8(step), start: Double(index), length: 1, hand: .right)
        }
    }

    func testFindsMajorKeys() {
        XCTAssertEqual(MusicKey.find(in: scale(from: 60)), MusicKey(tonic: 0, mode: .major))
        XCTAssertEqual(MusicKey.find(in: scale(from: 62)), MusicKey(tonic: 2, mode: .major))
        XCTAssertEqual(MusicKey.find(in: scale(from: 64)), MusicKey(tonic: 4, mode: .major))
    }

    func testFindsAMinor() {
        let tune: [(UInt8, Double)] = [(57, 2), (59, 1), (60, 1), (62, 1), (64, 2), (60, 1),
                                       (59, 1), (57, 2), (56, 1), (57, 2), (64, 1), (69, 2)]
        var start = 0.0
        let notes = tune.map { key, length -> Note in
            defer { start += length }
            return Note(key: key, start: start, length: length, hand: .right)
        }
        XCTAssertEqual(MusicKey.find(in: notes), MusicKey(tonic: 9, mode: .minor))
    }

    func testNoNotesIsCMajor() {
        XCTAssertEqual(MusicKey.find(in: []), MusicKey(tonic: 0, mode: .major))
    }

    func testAccidentalsAndNames() {
        XCTAssertEqual(MusicKey(tonic: 0, mode: .major).accidentals, 0)
        XCTAssertEqual(MusicKey(tonic: 4, mode: .major).accidentals, 4)
        XCTAssertEqual(MusicKey(tonic: 3, mode: .major).accidentals, 3)
        XCTAssertEqual(MusicKey(tonic: 6, mode: .major).accidentals, 6)
        XCTAssertEqual(MusicKey(tonic: 6, mode: .minor).accidentals, 3)
        XCTAssertEqual(MusicKey(tonic: 9, mode: .minor).accidentals, 0)
        XCTAssertEqual(MusicKey(tonic: 3, mode: .major).name, "Eb major")
        XCTAssertEqual(MusicKey(tonic: 4, mode: .major).moved(by: -1).name, "Eb major")
        XCTAssertEqual(MusicKey(tonic: 1, mode: .minor).name, "C# minor")
    }
}
