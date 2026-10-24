import Foundation
import XCTest
@testable import PianoCore

final class MIDIFileReaderTests: XCTestCase {
    func testFormat0ReadsNotesTempoMeterAndTitle() throws {
        let track = join(
            name("Ode"),
            [0x00, 0xFF, 0x51, 0x03, 0x09, 0x27, 0xC0], // 600000 us a beat: 100 bpm
            [0x00, 0xFF, 0x58, 0x04, 0x03, 0x02, 0x18, 0x08], // 3/4
            on(0, 60), off(480, 60),
            // Running status, and key on with force 0 as key off.
            [0x00, 0x90, 64, 80], vlq(240), [64, 0],
            end()
        )
        let song = try MIDIFileReader.read(smf(format: 0, ppq: 480, tracks: [track]))
        XCTAssertEqual(song.title, "Ode")
        XCTAssertEqual(song.beatsPerMinute, 100, accuracy: 0.001)
        XCTAssertEqual(song.beatsPerBar, 3)
        XCTAssertEqual(song.notes, [
            Note(key: 60, start: 0, length: 1, hand: .right),
            Note(key: 64, start: 1, length: 0.5, hand: .right),
        ])
    }

    func testTwoNoteTracksAreRightThenLeft() throws {
        let tempo = join(name("Song"), end())
        let first = join(on(0, 72), off(96, 72), end())
        // The second track is the left hand even where it plays above middle C.
        let second = join(on(0, 64), off(96, 64), on(0, 40), off(96, 40), end())
        let song = try MIDIFileReader.read(smf(format: 1, ppq: 96, tracks: [tempo, first, second]))
        XCTAssertEqual(song.notes.map(\.key), [64, 72, 40])
        XCTAssertEqual(song.notes.map(\.hand), [.left, .right, .left])
        XCTAssertEqual(song.notes.map(\.start), [0, 0, 1])
    }

    func testTrackNameSetsTheHand() throws {
        let left = join(name("Piano Left Hand"), on(0, 72), off(96, 72), end())
        let song = try MIDIFileReader.read(smf(format: 1, ppq: 96, tracks: [left]))
        XCTAssertEqual(song.notes.map(\.hand), [.left])
    }

    func testOneTrackSplitsAtMiddleC() throws {
        let track = join(on(0, 48), on(0, 60), off(96, 48), off(0, 60), end())
        let song = try MIDIFileReader.read(smf(format: 0, ppq: 96, tracks: [track]))
        XCTAssertEqual(song.notes, [
            Note(key: 48, start: 0, length: 1, hand: .left),
            Note(key: 60, start: 0, length: 1, hand: .right),
        ])
    }

    func testDrumsAndKeysOffThePianoAreDropped() throws {
        let track = join(
            [0x00, 0x99, 38, 100], vlq(96), [0x89, 38, 0], // channel 10
            on(0, 10), off(96, 10), // below A0
            on(0, 60), off(96, 60),
            end()
        )
        let song = try MIDIFileReader.read(smf(format: 0, ppq: 96, tracks: [track]))
        XCTAssertEqual(song.notes.map(\.key), [60])
        XCTAssertEqual(song.notes.first?.start, 2)
    }

    func testRepeatedKeyClosesTheOldestNoteFirst() throws {
        let track = join(on(0, 60), on(48, 60), off(48, 60), off(48, 60), end())
        let song = try MIDIFileReader.read(smf(format: 0, ppq: 96, tracks: [track]))
        XCTAssertEqual(song.notes.map(\.start), [0, 0.5])
        XCTAssertEqual(song.notes.map(\.length), [1, 1])
    }

    func testNoteStillDownAtTheEndOfTheTrackEndsThere() throws {
        let track = join(on(0, 60), [0x60, 0xFF, 0x2F, 0x00])
        let song = try MIDIFileReader.read(smf(format: 0, ppq: 96, tracks: [track]))
        XCTAssertEqual(song.notes.map(\.length), [1])
    }

    func testCutShortFileIsDamaged() {
        let track = join(on(0, 60), off(96, 60), end())
        let bytes = smf(format: 0, ppq: 96, tracks: [track]).dropLast(6)
        XCTAssertThrowsError(try MIDIFileReader.read(Data(bytes))) { error in
            guard case SongImportError.damaged = error else { return XCTFail("\(error)") }
        }
    }

    func testTimeInFramesIsUnsupported() {
        let data = smf(format: 0, ppq: 0xE728, tracks: [join(on(0, 60), off(96, 60), end())])
        XCTAssertThrowsError(try MIDIFileReader.read(data)) { error in
            guard case SongImportError.unsupported = error else { return XCTFail("\(error)") }
        }
    }

    // MARK: - A small MIDI file writer, for the tests

    private func smf(format: UInt16, ppq: UInt16, tracks: [[UInt8]]) -> Data {
        var bytes = join(Array("MThd".utf8), be32(6), be16(format), be16(UInt16(tracks.count)), be16(ppq))
        for track in tracks {
            bytes += join(Array("MTrk".utf8), be32(UInt32(track.count)), track)
        }
        return Data(bytes)
    }

    private func join(_ parts: [UInt8]...) -> [UInt8] { parts.flatMap { $0 } }
    private func on(_ delta: UInt32, _ key: UInt8) -> [UInt8] { join(vlq(delta), [0x90, key, 100]) }
    private func off(_ delta: UInt32, _ key: UInt8) -> [UInt8] { join(vlq(delta), [0x80, key, 64]) }
    private func end() -> [UInt8] { [0x00, 0xFF, 0x2F, 0x00] }
    private func name(_ text: String) -> [UInt8] {
        join([0x00, 0xFF, 0x03, UInt8(text.utf8.count)], Array(text.utf8))
    }

    private func vlq(_ value: UInt32) -> [UInt8] {
        var bytes = [UInt8(value & 0x7F)]
        var rest = value >> 7
        while rest > 0 {
            bytes.insert(UInt8(rest & 0x7F) | 0x80, at: 0)
            rest >>= 7
        }
        return bytes
    }

    private func be16(_ value: UInt16) -> [UInt8] { [UInt8(value >> 8), UInt8(value & 0xFF)] }
    private func be32(_ value: UInt32) -> [UInt8] { join(be16(UInt16(value >> 16)), be16(UInt16(value & 0xFFFF))) }
}

final class MusicXMLReaderTests: XCTestCase {
    static let expected = [
        Note(key: 48, start: 0, length: 4, hand: .left),
        Note(key: 60, start: 0, length: 1, hand: .right),
        Note(key: 64, start: 1, length: 1, hand: .right),
        Note(key: 67, start: 1, length: 1, hand: .right),
        Note(key: 72, start: 4, length: 6, hand: .right),
        Note(key: 70, start: 10, length: 2, hand: .right),
    ]

    func testScoreReadsStavesChordsRestsTiesAndGraceNotes() throws {
        let song = try MusicXMLReader.read(Data(Fixtures.scoreXML.utf8))
        XCTAssertEqual(song.title, "Test Tune")
        XCTAssertEqual(song.beatsPerMinute, 90)
        XCTAssertEqual(song.beatsPerBar, 4)
        XCTAssertEqual(song.notes, Self.expected)
    }

    func testTwoSingleStaffPartsAreRightThenLeft() throws {
        let xml = """
        <?xml version="1.0"?>
        <score-partwise>
          <part id="P1"><measure number="1"><attributes><divisions>1</divisions></attributes>
            <note><pitch><step>C</step><octave>3</octave></pitch><duration>1</duration></note>
          </measure></part>
          <part id="P2"><measure number="1"><attributes><divisions>1</divisions></attributes>
            <note><pitch><step>C</step><octave>5</octave></pitch><duration>1</duration></note>
          </measure></part>
        </score-partwise>
        """
        let song = try MusicXMLReader.read(Data(xml.utf8))
        XCTAssertEqual(song.notes, [
            Note(key: 48, start: 0, length: 1, hand: .right),
            Note(key: 72, start: 0, length: 1, hand: .left),
        ])
        XCTAssertEqual(song.beatsPerMinute, 120)
    }

    func testCompoundMeterCountsQuarterNotes() throws {
        let xml = """
        <score-partwise><part id="P1"><measure number="1">
          <attributes><divisions>1</divisions><time><beats>6</beats><beat-type>8</beat-type></time></attributes>
          <note><pitch><step>A</step><octave>4</octave></pitch><duration>3</duration></note>
        </measure></part></score-partwise>
        """
        let song = try MusicXMLReader.read(Data(xml.utf8))
        XCTAssertEqual(song.beatsPerBar, 3)
        XCTAssertEqual(song.notes.map(\.key), [69])
    }

    func testTimewiseScoreIsUnsupported() {
        let xml = "<?xml version=\"1.0\"?><score-timewise><measure number=\"1\"/></score-timewise>"
        XCTAssertThrowsError(try MusicXMLReader.read(Data(xml.utf8))) { error in
            guard case SongImportError.unsupported = error else { return XCTFail("\(error)") }
        }
    }

    func testBrokenXMLIsDamaged() {
        let xml = "<?xml version=\"1.0\"?><score-partwise><part id=\"P1\"><measure>"
        XCTAssertThrowsError(try MusicXMLReader.read(Data(xml.utf8))) { error in
            guard case SongImportError.damaged = error else { return XCTFail("\(error)") }
        }
    }
}

final class MXLArchiveTests: XCTestCase {
    func testInflateDynamicBlocks() throws {
        let bytes = try Inflater.inflate([UInt8](Fixtures.inflateDynamic), limit: 1 << 20)
        XCTAssertEqual(String(decoding: bytes, as: UTF8.self), Fixtures.inflateText)
    }

    func testInflateFixedBlock() throws {
        let bytes = try Inflater.inflate([UInt8](Fixtures.inflateFixed), limit: 1 << 20)
        XCTAssertEqual(String(decoding: bytes, as: UTF8.self), "abcabcabc piano")
    }

    func testInflateStopsAtTheLimit() {
        XCTAssertThrowsError(try Inflater.inflate([UInt8](Fixtures.inflateDynamic), limit: 1000))
    }

    func testCompressedMXLOpensTheScoreTheContainerNames() throws {
        let score = try MXLArchive.score(in: Fixtures.mxlDeflated)
        XCTAssertEqual(String(decoding: score, as: UTF8.self), Fixtures.scoreXML)
    }

    func testStoredMXLOpens() throws {
        let score = try MXLArchive.score(in: Fixtures.mxlStored)
        XCTAssertEqual(String(decoding: score, as: UTF8.self), Fixtures.scoreXML)
    }

    func testRootFile() {
        XCTAssertEqual(MXLArchive.rootFile(in: #"<rootfiles><rootfile full-path="a/b.xml"/></rootfiles>"#), "a/b.xml")
        XCTAssertNil(MXLArchive.rootFile(in: "<container/>"))
    }
}

final class SongImporterTests: XCTestCase {
    func testPicksTheReaderFromTheBytes() {
        XCTAssertEqual(SongImporter.format(of: Data("MThd".utf8)), .midi)
        XCTAssertEqual(SongImporter.format(of: Fixtures.mxlDeflated), .compressedMusicXML)
        XCTAssertEqual(SongImporter.format(of: Data(Fixtures.scoreXML.utf8)), .musicXML)
        XCTAssertNil(SongImporter.format(of: Data("hello".utf8)))
    }

    func testImportsAnMXLFile() throws {
        let song = try SongImporter.read(Fixtures.mxlDeflated, name: "file")
        XCTAssertEqual(song.title, "Test Tune")
        XCTAssertEqual(song.notes, MusicXMLReaderTests.expected)
    }

    func testFileNameIsTheTitleWhenTheFileHasNone() throws {
        let xml = """
        <score-partwise><part id="P1"><measure number="1">
          <note><pitch><step>C</step><octave>4</octave></pitch><duration>1</duration></note>
        </measure></part></score-partwise>
        """
        XCTAssertEqual(try SongImporter.read(Data(xml.utf8), name: "My Song").title, "My Song")
    }

    func testUnknownBytesAreRefused() {
        XCTAssertThrowsError(try SongImporter.read(Data("hello".utf8), name: "x")) { error in
            XCTAssertEqual(error as? SongImportError, .unknownFormat)
        }
    }

    func testFileWithNoNotesIsRefused() {
        let xml = "<score-partwise><part id=\"P1\"><measure number=\"1\"/></part></score-partwise>"
        XCTAssertThrowsError(try SongImporter.read(Data(xml.utf8), name: "x")) { error in
            XCTAssertEqual(error as? SongImportError, .noNotes)
        }
    }

    func testSongRoundTripsThroughJSON() throws {
        let song = try SongImporter.read(Data(Fixtures.scoreXML.utf8), name: "x")
        let copy = try JSONDecoder().decode(ImportedSong.self, from: JSONEncoder().encode(song))
        XCTAssertEqual(copy, song)
    }
}
