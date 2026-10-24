import PianoCore
import SwiftUI

struct ContentView: View {
    @Environment(KeyboardInput.self) private var keyboard

    var body: some View {
        VStack(spacing: 24) {
            banner
            Text(keyboard.lastKey.map { KeyName.label(of: $0) } ?? "Press a key")
                .font(.system(size: 56, weight: .semibold, design: .rounded))
                .monospacedDigit()
            Text(heldText)
                .font(.title3)
                .foregroundStyle(.secondary)
            Spacer()
            PianoKeyboardView(heldKeys: keyboard.heldKeys) { key, down in
                keyboard.touch(key, down: down)
            }
            .frame(height: 180)
        }
        .padding()
    }

    private var banner: some View {
        HStack {
            Image(systemName: keyboard.deviceNames.isEmpty ? "exclamationmark.triangle" : "pianokeys")
            Text(keyboard.deviceNames.isEmpty ? "Connect your keyboard" : "Connected: \(keyboard.deviceNames.joined(separator: ", "))")
            Spacer()
            if keyboard.pedalDown {
                Label("Pedal", systemImage: "shoe")
            }
        }
        .font(.headline)
        .padding(12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var heldText: String {
        let names = keyboard.heldKeys.sorted().map { KeyName.name(of: $0) }
        return names.isEmpty ? " " : names.joined(separator: "  ")
    }
}
