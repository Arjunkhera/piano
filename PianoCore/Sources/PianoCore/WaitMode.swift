/// What wait mode says about one key press.
public enum Mark: String, Codable, Sendable {
    /// A key of the step, on time.
    case right
    /// A key of the step, pressed more than half a beat after the step was due.
    case late
    /// A key that is not in the step. The step stays.
    case wrong
}

/// One key press that wait mode marked.
public struct Press: Equatable, Sendable {
    public var key: UInt8
    /// When the key went down, in seconds, on any clock that only goes forward.
    public var time: Double
    /// The index of the step that was waiting.
    public var step: Int
    public var mark: Mark

    public init(key: UInt8, time: Double, step: Int, mark: Mark) {
        self.key = key
        self.time = time
        self.step = step
        self.mark = mark
    }
}

/// Wait mode: the song stops at each step until you press each of its keys.
/// It marks every key press right, late or wrong, and counts the score.
public struct WaitMode: Sendable {
    /// The slowest and the fastest tempo, in beats per minute.
    public static let tempos: ClosedRange<Int> = 30...240

    public let steps: [PracticeStep]
    /// The tempo, in beats per minute. It sets when a key is late.
    public let tempo: Int
    /// The index of the step that waits for keys. It equals the step count
    /// when the part is done.
    public private(set) var stepIndex = 0
    /// The keys of the current step that are pressed.
    public private(set) var pressed: Set<UInt8> = []
    /// Every marked key press, in order.
    public private(set) var presses: [Press] = []

    /// When the current step is due, in seconds. Nil for the first step,
    /// which is never late.
    private var due: Double?
    /// The steps that had a wrong key.
    private var stepsWithWrongKey: Set<Int> = []

    public init(steps: [PracticeStep], tempo: Int) {
        self.steps = steps
        self.tempo = min(max(tempo, Self.tempos.lowerBound), Self.tempos.upperBound)
    }

    public init(notes: [Note], hands: Hands = .both, tempo: Int) {
        self.init(steps: PracticeStep.steps(from: notes, hands: hands), tempo: tempo)
    }

    public var isDone: Bool { stepIndex >= steps.count }

    /// The step that waits for keys, or nil when the part is done.
    public var current: PracticeStep? { isDone ? nil : steps[stepIndex] }

    /// The keys of the current step that are not pressed yet.
    public var waitingFor: Set<UInt8> { current.map { $0.keys.subtracting(pressed) } ?? [] }

    /// One beat, in seconds.
    public var secondsPerBeat: Double { 60 / Double(tempo) }

    /// Marks a key press at `time` seconds. Returns nil when the press gets
    /// no mark: the part is done, or the key of the step is already pressed.
    @discardableResult
    public mutating func press(_ key: UInt8, at time: Double) -> Mark? {
        guard let step = current else { return nil }
        guard step.keys.contains(key) else {
            stepsWithWrongKey.insert(stepIndex)
            presses.append(Press(key: key, time: time, step: stepIndex, mark: .wrong))
            return .wrong
        }
        guard !pressed.contains(key) else { return nil }
        pressed.insert(key)
        let late = due.map { time > $0 + secondsPerBeat / 2 } ?? false
        let mark: Mark = late ? .late : .right
        presses.append(Press(key: key, time: time, step: stepIndex, mark: mark))
        if pressed == step.keys {
            stepIndex += 1
            pressed = []
            if let next = current {
                due = time + (next.beat - step.beat) * secondsPerBeat
            }
        }
        return mark
    }

    /// The score of the steps that are done.
    public var score: PracticeScore {
        let done = steps.prefix(stepIndex)
        let notes = done.reduce(0) { $0 + $1.keys.count }
        let right = done.indices
            .filter { !stepsWithWrongKey.contains($0) }
            .reduce(0) { $0 + done[$1].keys.count }
        return PracticeScore(notes: notes, right: right,
                             wrongKeys: presses.filter { $0.mark == .wrong }.count,
                             late: presses.filter { $0.mark == .late }.count,
                             tempo: tempo)
    }
}
