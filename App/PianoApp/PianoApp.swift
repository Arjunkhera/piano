import SwiftUI

@main
struct PianoApp: App {
    @State private var keyboard = KeyboardInput()
    @State private var songs = SongLibrary()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(keyboard)
                .environment(songs)
                .onAppear { keyboard.start() }
        }
    }
}
