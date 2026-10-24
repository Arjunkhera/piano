import PianoCore
import SwiftUI

/// The home screen: the tunes to practise, the imported songs, and free play.
struct ContentView: View {
    @Environment(SongLibrary.self) private var library
    @State private var showSongs = false

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
                Section("My songs") {
                    ForEach(library.entries) { entry in
                        NavigationLink(entry.song.title) {
                            PracticeView(song: entry.song.practiceSong(id: entry.id))
                        }
                    }
                    Button("Import or manage songs", systemImage: "square.and.arrow.down") { showSongs = true }
                }
                Section {
                    NavigationLink("Free play") {
                        FreePlayView()
                    }
                }
            }
            .navigationTitle("Piano")
            .sheet(isPresented: $showSongs) { SongListView() }
        }
    }
}
