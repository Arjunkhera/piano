import Foundation
import Observation
import PianoCore
import SwiftUI

/// Keeps the basics course progress on the device, in the user defaults.
@Observable
@MainActor
final class BasicsProgressStore {
    private static let defaultsKey = "basics.progress"
    private let defaults: UserDefaults

    private(set) var progress: BasicsProgress

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        progress = defaults.data(forKey: Self.defaultsKey)
            .flatMap { try? JSONDecoder().decode(BasicsProgress.self, from: $0) } ?? BasicsProgress()
    }

    /// Keeps the score of an exercise, and saves a new pass. Returns true
    /// when the score passes.
    @discardableResult
    func record(_ score: PracticeScore, for exercise: BasicsExercise) -> Bool {
        var next = progress
        let passed = next.record(score, for: exercise)
        if next != progress {
            progress = next
            if let data = try? JSONEncoder().encode(progress) {
                defaults.set(data, forKey: Self.defaultsKey)
            }
        }
        return passed
    }
}

/// The basics course: the lessons in order. A lesson opens when you pass
/// each exercise of the lesson before it.
struct BasicsView: View {
    @State private var store = BasicsProgressStore()

    var body: some View {
        List {
            Section {
                Text("Seven short lessons before your first song. Pass each exercise of a lesson to open the next one.")
                    .foregroundStyle(.secondary)
            }
            Section("Lessons") {
                ForEach(BasicsCourse.lessons) { lesson in
                    let open = store.progress.isOpen(lesson)
                    NavigationLink {
                        BasicsLessonView(lesson: lesson, store: store)
                    } label: {
                        HStack {
                            Text("\(lesson.number). \(lesson.title)")
                            Spacer()
                            Image(systemName: icon(for: lesson))
                                .foregroundStyle(store.progress.isDone(lesson) ? Color.green : Color.secondary)
                        }
                    }
                    .disabled(!open)
                }
            }
        }
        .navigationTitle("Basics")
    }

    private func icon(for lesson: BasicsLesson) -> String {
        if store.progress.isDone(lesson) { return "checkmark.circle.fill" }
        return store.progress.isOpen(lesson) ? "circle" : "lock.fill"
    }
}

/// One lesson: the text that teaches the idea, and its exercises.
struct BasicsLessonView: View {
    let lesson: BasicsLesson
    let store: BasicsProgressStore

    var body: some View {
        List {
            Section {
                ForEach(Array(lesson.teach.enumerated()), id: \.offset) { _, paragraph in
                    Text(paragraph)
                        .font(.title3)
                }
            }
            Section("Exercises") {
                ForEach(lesson.exercises) { exercise in
                    NavigationLink {
                        ExerciseView(exercise: exercise, store: store)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(exercise.title)
                                Text(exercise.instruction)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if store.progress.hasPassed(exercise) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("\(lesson.number). \(lesson.title)")
    }
}
