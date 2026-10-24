import PianoCore
import SwiftUI
import UniformTypeIdentifiers

/// The list of songs, with the Import song button. D2 Layer 1.
struct SongListView: View {
    @Environment(SongLibrary.self) private var library
    @Environment(\.dismiss) private var dismiss
    @State private var picking = false

    var body: some View {
        NavigationStack {
            List {
                if let problem = library.problem {
                    Label(problem, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                }
                if library.entries.isEmpty {
                    Text("No songs yet. Import a MIDI or MusicXML file, or a MIDI file from piano-listen on your Mac.")
                        .foregroundStyle(.secondary)
                }
                ForEach(library.entries) { entry in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.song.title).font(.headline)
                        Text(summary(entry.song)).font(.subheadline).foregroundStyle(.secondary)
                    }
                }
                .onDelete { offsets in
                    for index in offsets { library.delete(library.entries[index]) }
                }
            }
            .navigationTitle("Songs")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Import song", systemImage: "square.and.arrow.down") { picking = true }
                }
            }
            .fileImporter(isPresented: $picking, allowedContentTypes: Self.songTypes) { result in
                if case .success(let url) = result { library.importFile(at: url) }
            }
        }
    }

    /// MIDI, MusicXML and .mxl. The reader checks the bytes, so a file with
    /// an extension the system does not know is allowed too.
    static let songTypes: [UTType] = [
        .midi,
        UTType(filenameExtension: "musicxml") ?? .xml,
        UTType(filenameExtension: "mxl") ?? .data,
        .xml,
        .data,
    ]

    private func summary(_ song: ImportedSong) -> String {
        let right = song.notes.filter { $0.hand == .right }.count
        let left = song.notes.count - right
        let beats = song.notes.map { $0.start + $0.length }.max() ?? 0
        let bars = Int((beats / max(song.beatsPerBar, 1)).rounded(.up))
        return "\(song.notes.count) notes: \(right) right hand, \(left) left hand. \(bars) bars at \(Int(song.beatsPerMinute)) beats a minute."
    }
}
