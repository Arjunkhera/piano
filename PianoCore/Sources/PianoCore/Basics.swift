/// One short task of the basics course, played in wait mode.
public struct BasicsExercise: Identifiable, Equatable, Sendable {
    /// What the screen shows for each step.
    public enum Hint: String, Codable, Sendable {
        /// The name of the key, and the key lit on the screen keyboard.
        case nameAndKey
        /// The name of the key only. You find the key yourself.
        case name
        /// The note on a staff only. You read it and find the key.
        case staff
    }

    /// "Lesson.exercise", such as "2.1". Saved progress uses it, so it never
    /// changes once it ships.
    public var id: String
    public var title: String
    /// One or two sentences that say what to do.
    public var instruction: String
    public var notes: [Note]
    public var hands: Hands
    public var hint: Hint
    /// True when a late key counts against a pass. The first lessons are
    /// about finding keys, so time does not count there.
    public var timed: Bool
    /// The tempo, in beats per minute.
    public var tempo: Int

    public init(id: String, title: String, instruction: String, notes: [Note], hands: Hands = .both,
                hint: Hint = .nameAndKey, timed: Bool = false, tempo: Int = 60) {
        self.id = id
        self.title = title
        self.instruction = instruction
        self.notes = notes
        self.hands = hands
        self.hint = hint
        self.timed = timed
        self.tempo = tempo
    }

    /// The notes that wait mode asks for: the notes of the hands of the
    /// exercise.
    public var practiceNotes: [Note] { notes.filter { hands.includes($0.hand) } }

    /// A new wait mode for the exercise, at step 1.
    public func waitMode() -> WaitMode {
        WaitMode(notes: notes, hands: hands, tempo: tempo)
    }

    /// True when the score passes the exercise: 90 percent or more of the
    /// notes right, and, when the exercise is timed, 10 percent or fewer late.
    public func passes(_ score: PracticeScore) -> Bool {
        guard score.notes > 0, score.right * 10 >= score.notes * 9 else { return false }
        return !timed || score.late * 10 <= score.notes
    }
}

/// One lesson of the basics course: a short text that teaches one idea, and
/// the exercises that practise it.
public struct BasicsLesson: Identifiable, Equatable, Sendable {
    /// The number of the lesson, from 1.
    public var number: Int
    public var title: String
    /// The text of the lesson, one paragraph each.
    public var teach: [String]
    public var exercises: [BasicsExercise]

    public var id: Int { number }

    public init(number: Int, title: String, teach: [String], exercises: [BasicsExercise]) {
        self.number = number
        self.title = title
        self.teach = teach
        self.exercises = exercises
    }
}

/// What you passed in the basics course. The app saves it on the device.
public struct BasicsProgress: Codable, Equatable, Sendable {
    /// The ids of the exercises you passed.
    public private(set) var passed: Set<String>

    public init(passed: Set<String> = []) {
        self.passed = passed
    }

    /// Keeps a pass of the exercise. A score that does not pass never takes
    /// a pass away. Returns true when the score passes.
    @discardableResult
    public mutating func record(_ score: PracticeScore, for exercise: BasicsExercise) -> Bool {
        guard exercise.passes(score) else { return false }
        passed.insert(exercise.id)
        return true
    }

    public func hasPassed(_ exercise: BasicsExercise) -> Bool {
        passed.contains(exercise.id)
    }

    /// True when you passed each exercise of the lesson.
    public func isDone(_ lesson: BasicsLesson) -> Bool {
        lesson.exercises.allSatisfy(hasPassed)
    }

    /// True when the lesson is open: it is the first lesson, or you passed
    /// each exercise of the lesson before it.
    public func isOpen(_ lesson: BasicsLesson, in lessons: [BasicsLesson] = BasicsCourse.lessons) -> Bool {
        guard let index = lessons.firstIndex(of: lesson) else { return false }
        return index == 0 || isDone(lessons[index - 1])
    }

    /// The first lesson that is open and not done, or nil when the course
    /// is done.
    public func nextLesson(in lessons: [BasicsLesson] = BasicsCourse.lessons) -> BasicsLesson? {
        lessons.first { isOpen($0, in: lessons) && !isDone($0) }
    }
}

/// The basics course: seven short lessons for a near beginner, before the
/// first song. The order follows the start of most beginner courses: middle
/// C, finger numbers, the C position for each hand, note names, beats, the
/// staff, then both hands. Each tune is a folk tune or older than 1900, and
/// it is a few lines of code, not a song file.
public enum BasicsCourse {
    public static let lessons: [BasicsLesson] = [
        findMiddleC, rightHand, leftHand, noteNames, beats, staff, bothHands,
    ]

    // MARK: 1. Find middle C

    static let findMiddleC = BasicsLesson(
        number: 1, title: "Find middle C",
        teach: [
            "Look at the black keys. They come in groups of two and groups of three.",
            "The white key just left of each group of two is a C. Your keyboard has 88 keys and 8 Cs.",
            "Middle C is the C nearest the middle of the keyboard, near the name of the keyboard. Its name is C4.",
        ],
        exercises: [
            BasicsExercise(
                id: "1.1", title: "The groups of two",
                instruction: "Play the two black keys of each group, from low to high.",
                notes: tune("C#3 D#3 C#4 D#4 C#5 D#5")),
            BasicsExercise(
                id: "1.2", title: "Every C",
                instruction: "Play each C on the keyboard, from the lowest to the highest.",
                notes: tune("C1 C2 C3 C4 C5 C6 C7 C8")),
            BasicsExercise(
                id: "1.3", title: "Middle C",
                instruction: "Play middle C four times with your right thumb.",
                notes: tune("C4/1/1 C4/1/1 C4/1/1 C4/1/1")),
        ])

    // MARK: 2. Right hand, C position

    static let rightHand = BasicsLesson(
        number: 2, title: "Right hand in C position",
        teach: [
            "Each finger has a number. The thumb is 1, the pointer 2, the middle finger 3, the ring finger 4 and the little finger 5. The numbers are the same on both hands.",
            "Put your right thumb on middle C. Put one finger on each white key after it: 2 on D, 3 on E, 4 on F and 5 on G. This is the C position.",
            "Keep your fingers curved, and keep each finger over its key.",
        ],
        exercises: [
            BasicsExercise(
                id: "2.1", title: "Up five keys",
                instruction: "Play C, D, E, F and G with fingers 1 to 5.",
                notes: tune("C4/1/1 D4/1/2 E4/1/3 F4/1/4 G4/1/5")),
            BasicsExercise(
                id: "2.2", title: "Up and down",
                instruction: "Go up to G, then back down to C. Do not look at your hand.",
                notes: tune("C4/1/1 D4/1/2 E4/1/3 F4/1/4 G4/1/5 F4/1/4 E4/1/3 D4/1/2 C4/1/1")),
            BasicsExercise(
                id: "2.3", title: "Skips",
                instruction: "Play C, E and G, and back. Skip the key between.",
                notes: tune("C4/1/1 E4/1/3 G4/1/5 E4/1/3 C4/1/1")),
        ])

    // MARK: 3. Left hand, C position

    static let leftHand = BasicsLesson(
        number: 3, title: "Left hand in C position",
        teach: [
            "Find the C below middle C. Its name is C3.",
            "Put your left little finger, 5, on C3. Then 4 on D, 3 on E, 2 on F, and your thumb, 1, on G.",
            "The left hand counts the other way: the thumb is nearest middle C.",
        ],
        exercises: [
            BasicsExercise(
                id: "3.1", title: "Up five keys",
                instruction: "Play C3, D3, E3, F3 and G3 with fingers 5 to 1.",
                notes: tune("C3/1/5 D3/1/4 E3/1/3 F3/1/2 G3/1/1", hand: .left)),
            BasicsExercise(
                id: "3.2", title: "Down and up",
                instruction: "Start with your thumb on G3. Go down to C3 and back up.",
                notes: tune("G3/1/1 F3/1/2 E3/1/3 D3/1/4 C3/1/5 D3/1/4 E3/1/3 F3/1/2 G3/1/1", hand: .left)),
            BasicsExercise(
                id: "3.3", title: "Skips",
                instruction: "Play C, E and G with fingers 5, 3 and 1, and back.",
                notes: tune("C3/1/5 E3/1/3 G3/1/1 E3/1/3 C3/1/5", hand: .left)),
        ])

    // MARK: 4. Note names

    static let noteNames = BasicsLesson(
        number: 4, title: "Note names",
        teach: [
            "The white keys use seven letters, A to G. After G comes A again.",
            "D is between the two black keys. F is just left of the three black keys.",
            "Now the screen gives the name only. It does not light the key. Find each key yourself.",
        ],
        exercises: [
            BasicsExercise(
                id: "4.1", title: "Names in C position",
                instruction: "Keep your right hand in C position. Play each key that the screen names.",
                notes: tune("E4/1/3 G4/1/5 D4/1/2 F4/1/4 C4/1/1 E4/1/3 D4/1/2 G4/1/5"),
                hint: .name),
            BasicsExercise(
                id: "4.2", title: "Every D",
                instruction: "Find D between the two black keys, in three places.",
                notes: tune("D3 D4 D5"),
                hint: .name),
            BasicsExercise(
                id: "4.3", title: "F and G",
                instruction: "Find F left of the three black keys, and the G next to it.",
                notes: tune("F3 G3 F4 G4 F5 G5"),
                hint: .name),
        ])

    // MARK: 5. Beats

    static let beats = BasicsLesson(
        number: 5, title: "Beats: quarter and half notes",
        teach: [
            "Music has a steady beat. Count it out loud: 1, 2, 3, 4.",
            "A quarter note lasts one beat. A half note lasts two beats. A whole note lasts four.",
            "From now on, time counts. The screen marks a key late when it comes more than half a beat after its time. Count, and play each key on its beat.",
        ],
        exercises: [
            BasicsExercise(
                id: "5.1", title: "Hot Cross Buns",
                instruction: "A folk tune. Hold each half note for two beats.",
                notes: tune("E4/1/3 D4/1/2 C4/2/1 E4/1/3 D4/1/2 C4/2/1 C4/1/1 C4/1/1 C4/1/1 C4/1/1 D4/1/2 D4/1/2 D4/1/2 D4/1/2 E4/1/3 D4/1/2 C4/2/1"),
                timed: true),
            BasicsExercise(
                id: "5.2", title: "Mary Had a Little Lamb",
                instruction: "A folk tune. The last note is a whole note: hold it for four beats.",
                notes: mary,
                timed: true),
        ])

    // MARK: 6. The staff

    static let staff = BasicsLesson(
        number: 6, title: "Read notes on the staff",
        teach: [
            "Music is written on five lines, the staff. A note sits on a line or in a space. A higher note means a higher key.",
            "On the treble staff, E4 sits on the bottom line and G4 on the second line. D4 hangs just below the staff. Middle C sits on a small line of its own below the staff.",
            "Now the screen shows the note on the staff only. Read it, and play it.",
        ],
        exercises: [
            BasicsExercise(
                id: "6.1", title: "Read and play",
                instruction: "Keep your right hand in C position. Read each note and play it.",
                notes: tune("C4/1/1 E4/1/3 G4/1/5 D4/1/2 F4/1/4 E4/1/3 C4/1/1 G4/1/5"),
                hint: .staff),
            BasicsExercise(
                id: "6.2", title: "Read a tune",
                instruction: "The first line of \"Ode to Joy\", by Beethoven. Read it from the staff.",
                notes: tune("E4/1/3 E4/1/3 F4/1/4 G4/1/5 G4/1/5 F4/1/4 E4/1/3 D4/1/2 C4/1/1 C4/1/1 D4/1/2 E4/1/3 E4/1.5/3 D4/0.5/2 D4/2/2"),
                hint: .staff),
        ])

    // MARK: 7. Both hands

    static let bothHands = BasicsLesson(
        number: 7, title: "Your first tune with both hands",
        teach: [
            "Put both hands in C position: the left little finger on C3, the right thumb on C4.",
            "The left hand plays one long note at the start of each bar. The right hand plays the tune.",
            "First play the left hand alone. Then play both hands. Press the two keys of a step at the same time.",
        ],
        exercises: [
            BasicsExercise(
                id: "7.1", title: "Left hand alone",
                instruction: "Play the left hand of \"Mary Had a Little Lamb\": C3 or G3, one note each bar.",
                notes: maryBothHands, hands: .left, timed: true),
            BasicsExercise(
                id: "7.2", title: "Both hands",
                instruction: "Play \"Mary Had a Little Lamb\" with both hands.",
                notes: maryBothHands, hands: .both, timed: true),
        ])

    // MARK: Tunes

    /// "Mary Had a Little Lamb", a folk tune, for the right hand.
    static let mary = tune(
        "E4/1/3 D4/1/2 C4/1/1 D4/1/2 E4/1/3 E4/1/3 E4/2/3 D4/1/2 D4/1/2 D4/2/2 E4/1/3 G4/1/5 G4/2/5 "
            + "E4/1/3 D4/1/2 C4/1/1 D4/1/2 E4/1/3 E4/1/3 E4/1/3 E4/1/3 D4/1/2 D4/1/2 E4/1/3 D4/1/2 C4/4/1")

    /// "Mary Had a Little Lamb" with a left-hand note at the start of each
    /// bar: C3, or G3 under the bars on D.
    static let maryBothHands: [Note] = {
        let roots = "C3 C3 G3 C3 C3 C3 G3 C3".split(separator: " ")
        let left = roots.enumerated().map { bar, name in
            Note(key: key(String(name)), start: Double(bar * 4), length: 4, hand: .left,
                 finger: name == "C3" ? 5 : 1)
        }
        return (mary + left).sorted { ($0.start, $0.key) < ($1.start, $1.key) }
    }()

    // MARK: Helpers

    /// Notes, one after the other, from words such as "E4/1/3": the key, the
    /// beats and the finger. The beats are 1 and the finger is unknown when
    /// they are left out.
    static func tune(_ text: String, hand: Note.Hand = .right) -> [Note] {
        var start = 0.0
        return text.split(separator: " ").map { word in
            let parts = word.split(separator: "/").map(String.init)
            let beats = parts.count > 1 ? Double(parts[1])! : 1
            let finger = parts.count > 2 ? Int(parts[2])! : nil
            defer { start += beats }
            return Note(key: key(parts[0]), start: start, length: beats, hand: hand, finger: finger)
        }
    }

    /// The MIDI key of a name such as "C4" or "C#3".
    static func key(_ name: String) -> UInt8 {
        let letters: [Character: Int] = ["C": 0, "D": 2, "E": 4, "F": 5, "G": 7, "A": 9, "B": 11]
        var rest = Substring(name)
        guard let first = rest.first, var pitch = letters[first] else { preconditionFailure("bad key name \(name)") }
        rest = rest.dropFirst()
        if rest.first == "#" {
            pitch += 1
            rest = rest.dropFirst()
        }
        guard let octave = Int(rest) else { preconditionFailure("bad key name \(name)") }
        return UInt8((octave + 1) * 12 + pitch)
    }
}
