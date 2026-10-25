import PianoCore
import SwiftUI

/// The home screen: the basics course, the tunes to practise, the classical
/// pieces, the imported songs, and free play.
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
                Section("Start here") {
                    NavigationLink("Basics course") {
                        BasicsView()
                    }
                }
                Section("Practice") {
                    ForEach(BuiltInSong.all.filter { $0.composer == nil }) { song in
                        NavigationLink(song.title) {
                            PracticeView(song: song)
                        }
                    }
                }
                Section("Classical") {
                    ForEach(BuiltInSong.classical) { song in
                        NavigationLink {
                            PracticeView(song: song)
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(song.title)
                                Text(song.composer ?? "").font(.subheadline).foregroundStyle(.secondary)
                            }
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
