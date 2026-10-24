import Foundation
import Observation
import PianoCore

/// The state of the practice screen: the song, the choices, and wait mode.
/// The rules live in PianoCore. This class only joins them to the keyboard.
@Observable
@MainActor
final class PracticeModel {
    /// The last marked key, so the screen can colour it.
    struct Flash: Equatable {
        var key: UInt8
        var mark: Mark
    }

    let song: BuiltInSong
    private(set) var level: Level = .beginner
    private(set) var hands: Hands = .both
    private(set) var tempo = 60
    private(set) var partIndex = 0
    private(set) var lesson: Lesson
    private(set) var parts: [LessonPart]
    private(set) var wait: WaitMode
    private(set) var flash: Flash?

    init(song: BuiltInSong) {
        self.song = song
        let lesson = LessonMaker.make(.beginner, from: song.notes, beatsPerBar: song.beatsPerBar)
        let parts = lesson.parts()
        self.lesson = lesson
        self.parts = parts
        wait = WaitMode(notes: parts.first?.notes ?? [], hands: .both, tempo: 60)
    }

    var part: LessonPart? { parts.indices.contains(partIndex) ? parts[partIndex] : nil }
    var hasNextPart: Bool { partIndex + 1 < parts.count }

    /// The steps after the current one, for the row of next notes.
    var nextSteps: ArraySlice<PracticeStep> {
        let from = min(wait.stepIndex + 1, wait.steps.count)
        return wait.steps[from..<min(from + 8, wait.steps.count)]
    }

    func choose(level: Level) {
        guard level != self.level else { return }
        self.level = level
        lesson = LessonMaker.make(level, from: song.notes, beatsPerBar: song.beatsPerBar)
        parts = lesson.parts()
        partIndex = min(partIndex, max(parts.count - 1, 0))
        restart()
    }

    func choose(hands: Hands) {
        self.hands = hands
        restart()
    }

    func choose(tempo: Int) {
        self.tempo = min(max(tempo, WaitMode.tempos.lowerBound), WaitMode.tempos.upperBound)
        restart()
    }

    func choose(part index: Int) {
        partIndex = min(max(index, 0), max(parts.count - 1, 0))
        restart()
    }

    func nextPart() {
        choose(part: partIndex + 1)
    }

    /// Starts the current part again, from step 1.
    func restart() {
        wait = WaitMode(notes: part?.notes ?? [], hands: hands, tempo: tempo)
        flash = nil
    }

    /// Marks a key press. Wait mode reads key presses only.
    func handle(_ event: KeyEvent, at time: Double) {
        guard event.kind == .keyOn, let mark = wait.press(event.key, at: time) else { return }
        flash = Flash(key: event.key, mark: mark)
    }
}
