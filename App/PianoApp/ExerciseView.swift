import Foundation
import Observation
import PianoCore
import SwiftUI

/// The state of one basics exercise in wait mode. The rules live in
/// PianoCore. This class joins them to the keyboard and to the saved progress.
@Observable
@MainActor
final class ExerciseModel {
    let exercise: BasicsExercise
    private let store: BasicsProgressStore
    private(set) var wait: WaitMode
    private(set) var flash: PracticeModel.Flash?
    /// True or false once the exercise is done: did the score pass?
    private(set) var passed: Bool?

    init(exercise: BasicsExercise, store: BasicsProgressStore) {
        self.exercise = exercise
        self.store = store
        wait = exercise.waitMode()
    }

    /// The steps after the current one, to read ahead.
    var nextSteps: ArraySlice<PracticeStep> {
        let from = min(wait.stepIndex + 1, wait.steps.count)
        return wait.steps[from..<min(from + 6, wait.steps.count)]
    }

    /// Starts the exercise again, from step 1.
    func restart() {
        wait = exercise.waitMode()
        flash = nil
        passed = nil
    }

    /// Marks a key press. When it ends the exercise, it keeps the score.
    func handle(_ event: KeyEvent, at time: Double) {
        guard event.kind == .keyOn, let mark = wait.press(event.key, at: time) else { return }
        flash = PracticeModel.Flash(key: event.key, mark: mark)
        if wait.isDone && passed == nil {
            passed = store.record(wait.score, for: exercise)
        }
    }
}

/// One exercise of the basics course. It works like the practice screen,
/// but the hint changes with the lesson: the name and a lit key, the name
/// only, or the note on a staff only.
struct ExerciseView: View {
    @Environment(KeyboardInput.self) private var keyboard
    @State private var model: ExerciseModel

    init(exercise: BasicsExercise, store: BasicsProgressStore) {
        _model = State(initialValue: ExerciseModel(exercise: exercise, store: store))
    }

    var body: some View {
        VStack(spacing: 16) {
            ConnectionBanner()
            Text(model.exercise.instruction)
                .font(.title3)
                .multilineTextAlignment(.center)
            if model.wait.isDone {
                scoreCard
            } else {
                prompt
            }
            Spacer()
            PianoKeyboardView(heldKeys: keyboard.heldKeys, keyColors: keyColors) { key, down in
                keyboard.touch(key, down: down)
            }
            .frame(height: 180)
        }
        .padding()
        .navigationTitle(model.exercise.title)
        .onAppear {
            let model = model
            keyboard.onEvent = { event, time in model.handle(event, at: time) }
        }
        .onDisappear { keyboard.onEvent = nil }
    }

    // MARK: Prompt

    private var prompt: some View {
        VStack(spacing: 12) {
            if let step = model.wait.current {
                Text("Step \(model.wait.stepIndex + 1) of \(model.wait.steps.count)")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                switch model.exercise.hint {
                case .nameAndKey, .name:
                    Text("Play \(names(of: model.wait.waitingFor))")
                        .font(.system(size: 48, weight: .semibold, design: .rounded))
                case .staff:
                    StaffView(clef: Clef.of(step.notes.first?.hand ?? .right),
                              keys: [step.keys.min() ?? 60] + model.nextSteps.compactMap { $0.keys.min() })
                }
                Text(fingerText(step))
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            if let flash = model.flash {
                Label(flashText(flash), systemImage: flash.mark == .wrong ? "xmark.circle.fill" : "checkmark.circle.fill")
                    .foregroundStyle(flash.mark == .wrong ? Color.red : Color.green)
                    .font(.title3)
            }
            if model.exercise.hint != .staff && !model.nextSteps.isEmpty {
                HStack(spacing: 14) {
                    Text("Next:").foregroundStyle(.secondary)
                    ForEach(Array(model.nextSteps.enumerated()), id: \.offset) { _, step in
                        Text(names(of: step.keys))
                            .font(.title3.monospaced())
                    }
                }
            }
        }
    }

    // MARK: Score

    private var scoreCard: some View {
        let score = model.wait.score
        let passed = model.passed ?? false
        return VStack(spacing: 16) {
            Label(passed ? "Passed" : "Not yet", systemImage: passed ? "checkmark.seal.fill" : "arrow.clockwise")
                .font(.system(size: 36, weight: .semibold, design: .rounded))
                .foregroundStyle(passed ? Color.green : Color.orange)
            Text(score.summary)
                .font(.title3)
            Text(passed ? "Go back for the next exercise, or play it again." : passText)
                .foregroundStyle(.secondary)
            Button("Again") { model.restart() }
                .buttonStyle(.borderedProminent)
        }
        .padding(24)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var passText: String {
        model.exercise.timed
            ? "To pass, get 9 of 10 notes right, with 1 in 10 late or fewer."
            : "To pass, get 9 of 10 notes right."
    }

    // MARK: Helpers

    /// The key to press shows in orange, but only when the hint lights it.
    /// A held key shows green when its mark is right or late, and red when
    /// it is wrong.
    private var keyColors: [UInt8: Color] {
        var colors: [UInt8: Color] = [:]
        if model.exercise.hint == .nameAndKey {
            for key in model.wait.waitingFor { colors[key] = .orange.opacity(0.7) }
        }
        if let flash = model.flash, keyboard.heldKeys.contains(flash.key) {
            colors[flash.key] = flash.mark == .wrong ? .red : .green
        }
        return colors
    }

    private func flashText(_ flash: PracticeModel.Flash) -> String {
        let name = KeyName.name(of: flash.key)
        switch flash.mark {
        case .right: return "\(name): right"
        case .late: return "\(name): right, but late"
        case .wrong: return "\(name): wrong key"
        }
    }

    private func names(of keys: Set<UInt8>) -> String {
        keys.sorted().map { KeyName.name(of: $0) }.joined(separator: " + ")
    }

    /// Which hand, and the finger when it is known.
    private func fingerText(_ step: PracticeStep) -> String {
        step.notes.map { note in
            let hand = note.hand == .left ? "Left hand" : "Right hand"
            return note.finger.map { "\(hand), finger \($0)" } ?? hand
        }
        .joined(separator: ", ")
    }
}
