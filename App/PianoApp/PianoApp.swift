import SwiftUI

@main
struct PianoApp: App {
    @State private var keyboard = KeyboardInput()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(keyboard)
                .onAppear { keyboard.start() }
        }
    }
}
