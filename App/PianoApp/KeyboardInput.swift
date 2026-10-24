import CoreMIDI
import Foundation
import Observation
import PianoCore

/// Reads every MIDI source with Core MIDI and keeps the set of held keys.
@Observable
@MainActor
final class KeyboardInput {
    /// The keys that are down now.
    private(set) var heldKeys: Set<UInt8> = []
    /// The names of the connected MIDI sources.
    private(set) var deviceNames: [String] = []
    /// The last key pressed, for the label.
    private(set) var lastKey: UInt8?
    private(set) var pedalDown = false

    private var client = MIDIClientRef()
    private var port = MIDIPortRef()
    private var parser = MIDIParser()

    func start() {
        guard client == 0 else { return }
        MIDIClientCreateWithBlock("Piano" as CFString, &client) { [weak self] notification in
            let id = notification.pointee.messageID
            guard id == .msgObjectAdded || id == .msgObjectRemoved || id == .msgSetupChanged else { return }
            Task { @MainActor in self?.connectSources() }
        }
        MIDIInputPortCreateWithProtocol(client, "Piano input" as CFString, ._1_0, &port) { [weak self] eventList, _ in
            let bytes = Self.bytes(from: eventList)
            Task { @MainActor in self?.handle(bytes) }
        }
        connectSources()
    }

    /// Lights a key from a touch on screen, when no keyboard is connected.
    func touch(_ key: UInt8, down: Bool) {
        apply(KeyEvent(kind: down ? .keyOn : .keyOff, key: key, force: down ? 64 : 0))
    }

    private func connectSources() {
        var names: [String] = []
        for index in 0..<MIDIGetNumberOfSources() {
            let source = MIDIGetSource(index)
            MIDIPortConnectSource(port, source, nil)
            var name: Unmanaged<CFString>?
            if MIDIObjectGetStringProperty(source, kMIDIPropertyDisplayName, &name) == noErr, let name {
                names.append(name.takeRetainedValue() as String)
            }
        }
        if names.isEmpty {
            // The cable came out: no key can still be down.
            heldKeys.removeAll()
            pedalDown = false
            parser.reset()
        }
        deviceNames = names
    }

    private func handle(_ bytes: [UInt8]) {
        for event in parser.parse(bytes) {
            apply(event)
        }
    }

    private func apply(_ event: KeyEvent) {
        switch event.kind {
        case .keyOn:
            heldKeys.insert(event.key)
            lastKey = event.key
        case .keyOff:
            heldKeys.remove(event.key)
        case .pedal:
            pedalDown = event.force >= 64
        }
    }

    /// Turns a MIDI 1.0 event list (Universal MIDI Packets) back into MIDI 1.0 bytes.
    nonisolated private static func bytes(from list: UnsafePointer<MIDIEventList>) -> [UInt8] {
        var bytes: [UInt8] = []
        for packet in list.unsafeSequence() {
            let words = MIDIEventPacket.WordCollection(packet)
            for word in words {
                // Message type 2 is a MIDI 1.0 channel voice message in one 32-bit word.
                guard word >> 28 == 0x2 else { continue }
                let status = UInt8((word >> 16) & 0xFF)
                let first = UInt8((word >> 8) & 0x7F)
                let second = UInt8(word & 0x7F)
                bytes.append(status)
                bytes.append(first)
                if status & 0xF0 != 0xC0 && status & 0xF0 != 0xD0 {
                    bytes.append(second)
                }
            }
        }
        return bytes
    }
}
