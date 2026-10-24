import PianoCore
import SwiftUI

/// The D1 screen: it lights each key you press and names it.
struct FreePlayView: View {
    @Environment(KeyboardInput.self) private var keyboard

    var body: some View {
        VStack(spacing: 24) {
            ConnectionBanner()
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
        .navigationTitle("Free play")
    }

    private var heldText: String {
        let names = keyboard.heldKeys.sorted().map { KeyName.name(of: $0) }
        return names.isEmpty ? " " : names.joined(separator: "  ")
    }
}

/// Says whether a keyboard is connected, and shows the pedal.
struct ConnectionBanner: View {
    @Environment(KeyboardInput.self) private var keyboard

    var body: some View {
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
}
