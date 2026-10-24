import Foundation
import Observation
import PianoCore

/// The songs on this device. Each song is one JSON file in Application
/// Support/Songs. Songs never leave the device.
@Observable
@MainActor
final class SongLibrary {
    struct Entry: Identifiable, Equatable {
        var id: String { file.lastPathComponent }
        var file: URL
        var song: ImportedSong
    }

    private(set) var entries: [Entry] = []
    /// The last import problem, for the screen.
    var problem: String?

    private let folder: URL

    init() {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        folder = support.appendingPathComponent("Songs", isDirectory: true)
        load()
    }

    func load() {
        let files = (try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)) ?? []
        entries = files
            .filter { $0.pathExtension == "json" }
            .compactMap { file in
                guard let data = try? Data(contentsOf: file),
                      let song = try? JSONDecoder().decode(ImportedSong.self, from: data)
                else { return nil }
                return Entry(file: file, song: song)
            }
            .sorted { $0.song.title.localizedCaseInsensitiveCompare($1.song.title) == .orderedAscending }
    }

    /// Reads a MIDI, MusicXML or .mxl file that the user picked, and keeps it.
    func importFile(at url: URL) {
        let scoped = url.startAccessingSecurityScopedResource()
        defer { if scoped { url.stopAccessingSecurityScopedResource() } }
        do {
            let data = try Data(contentsOf: url)
            let song = try SongImporter.read(data, name: url.deletingPathExtension().lastPathComponent)
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            let file = folder.appendingPathComponent(UUID().uuidString + ".json")
            try JSONEncoder().encode(song).write(to: file, options: .atomic)
            problem = nil
            load()
        } catch let error as SongImportError {
            problem = error.description
        } catch {
            problem = error.localizedDescription
        }
    }

    func delete(_ entry: Entry) {
        try? FileManager.default.removeItem(at: entry.file)
        load()
    }
}
