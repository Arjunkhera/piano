import PianoCore
import SwiftUI

/// Wait mode: the screen lights the next key and waits for it. Each key
/// press shows green when it is right and red when it is wrong. The score
/// and a tip come at the end of the part.
struct PracticeView: View {
    @Environment(KeyboardInput.self) private var keyboard
    @State private var model: PracticeModel

    init(song: BuiltInSong) {
        _model = State(initialValue: PracticeModel(song: song))
    }

    var body: some View {
        VStack(spacing: 16) {
            ConnectionBanner()
            choices
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
        .navigationTitle(model.song.title)
        .onAppear {
            let model = model
            keyboard.onEvent = { event, time in model.handle(event, at: time) }
        }
        .onDisappear { keyboard.onEvent = nil }
    }

    // MARK: Choices

    private var choices: some View {
        VStack(spacing: 12) {
            HStack {
                Picker("Level", selection: Binding(get: { model.level }, set: { model.choose(level: $0) })) {
                    ForEach(Level.allCases, id: \.self) { Text($0.rawValue.capitalized).tag($0) }
                }
                Picker("Hands", selection: Binding(get: { model.hands }, set: { model.choose(hands: $0) })) {
                    Text("Right hand").tag(Hands.right)
                    Text("Left hand").tag(Hands.left)
                    Text("Both hands").tag(Hands.both)
                }
            }
            .pickerStyle(.segmented)
            HStack {
                Picker("Part", selection: Binding(get: { model.partIndex }, set: { model.choose(part: $0) })) {
                    ForEach(Array(model.parts.enumerated()), id: \.offset) { index, part in
                        Text("Part \(part.number): bars \(part.firstBar) to \(part.firstBar + part.bars - 1)").tag(index)
                    }
                }
                Spacer()
                Stepper("\(model.tempo) beats per minute",
                        value: Binding(get: { model.tempo }, set: { model.choose(tempo: $0) }),
                        in: WaitMode.tempos, step: 5)
                    .fixedSize()
            }
        }
    }

    // MARK: Prompt

    private var prompt: some View {
        VStack(spacing: 12) {
            if let step = model.wait.current {
                Text("Step \(model.wait.stepIndex + 1) of \(model.wait.steps.count)")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Text("Play \(names(of: model.wait.waitingFor))")
                    .font(.system(size: 48, weight: .semibold, design: .rounded))
                Text(handText(step))
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            if let flash = model.flash {
                Label(flashText(flash), systemImage: flash.mark == .wrong ? "xmark.circle.fill" : "checkmark.circle.fill")
                    .foregroundStyle(color(for: flash.mark))
                    .font(.title3)
            }
            if !model.nextSteps.isEmpty {
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
        let tip = score.tip
        return VStack(spacing: 16) {
            Text(score.summary)
                .font(.system(size: 36, weight: .semibold, design: .rounded))
            Text(tip.text)
                .font(.title3)
            HStack(spacing: 16) {
                Button("Again") { model.restart() }
                    .buttonStyle(.bordered)
                if tip.tempo != model.tempo {
                    Button("Again at \(tip.tempo)") { model.choose(tempo: tip.tempo) }
                        .buttonStyle(.borderedProminent)
                }
                if model.hasNextPart {
                    Button("Next part") { model.nextPart() }
                        .buttonStyle(.bordered)
                }
            }
        }
        .padding(24)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: Helpers

    /// The keys to press show in orange. A held key shows green when its
    /// mark is right or late, and red when it is wrong.
    private var keyColors: [UInt8: Color] {
        var colors: [UInt8: Color] = [:]
        for key in model.wait.waitingFor { colors[key] = .orange.opacity(0.7) }
        if let flash = model.flash, keyboard.heldKeys.contains(flash.key) {
            colors[flash.key] = color(for: flash.mark)
        }
        return colors
    }

    private func color(for mark: Mark) -> Color {
        mark == .wrong ? .red : .green
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

    private func handText(_ step: PracticeStep) -> String {
        let hands = Set(step.notes.map(\.hand))
        if hands.count > 1 { return "Both hands" }
        let fingers = step.notes.compactMap(\.finger)
        let hand = hands.first == .left ? "Left hand" : "Right hand"
        return fingers.isEmpty ? hand : "\(hand), finger \(fingers.map(String.init).joined(separator: " + "))"
    }
}
