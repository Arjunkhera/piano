import PianoCore
import SwiftUI

/// The home screen: the tunes to practise, and free play.
struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ConnectionBanner()
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
                Section("Practice") {
                    ForEach(BuiltInSong.all) { song in
                        NavigationLink(song.title) {
                            PracticeView(song: song)
                        }
                    }
                }
                Section {
                    NavigationLink("Free play") {
                        FreePlayView()
                    }
                }
            }
            .navigationTitle("Piano")
        }
    }
}
