import CoreMIDI
import Foundation
import Observation
import PianoCore

/// Reads every MIDI device with Core MIDI and keeps the set of held keys.
///
/// Each device has its own parser and its own held keys, so a device that
/// goes away takes only its own keys. All packets go through one queue, so
/// they reach the screen in the order they came.
@Observable
@MainActor
final class KeyboardInput {
    /// The keys that are down now, on every device and on screen.
    private(set) var heldKeys: Set<UInt8> = []
    /// The names of the connected MIDI devices.
    private(set) var deviceNames: [String] = []
    /// The last key pressed, for the label.
    private(set) var lastKey: UInt8?
    private(set) var pedalDown = false
    /// Gets each key event, with the time it came in seconds. Practice sets it.
    @ObservationIgnored var onEvent: ((KeyEvent, Double) -> Void)?

    private struct Packet: Sendable {
        var source: MIDIEndpointRef
        var bytes: [UInt8]
        var time: Double
    }

    private struct Source {
        var parser = MIDIParser()
        var held: Set<UInt8> = []
        var pedalDown = false
    }

    private var client = MIDIClientRef()
    private var port = MIDIPortRef()
    private var sources: [MIDIEndpointRef: Source] = [:]
    private var touchedKeys: Set<UInt8> = []
    private let packets: AsyncStream<Packet>
    private let packetQueue: AsyncStream<Packet>.Continuation

    init() {
        let (packets, packetQueue) = AsyncStream.makeStream(of: Packet.self)
        self.packets = packets
        self.packetQueue = packetQueue
    }

    func start() {
        guard client == 0 else { return }
        MIDIClientCreateWithBlock("Piano" as CFString, &client) { [weak self] notification in
            let id = notification.pointee.messageID
            guard id == .msgObjectAdded || id == .msgObjectRemoved || id == .msgSetupChanged else { return }
            Task { @MainActor in self?.connectSources() }
        }
        let queue = packetQueue
        MIDIInputPortCreateWithProtocol(client, "Piano input" as CFString, ._1_0, &port) { eventList, refCon in
            // The refCon of each connection is its source, as connectSources sets it.
            let source = MIDIEndpointRef(truncatingIfNeeded: UInt(bitPattern: refCon))
            queue.yield(Packet(source: source, bytes: Self.bytes(from: eventList),
                               time: ProcessInfo.processInfo.systemUptime))
        }
        connectSources()
        let packets = self.packets
        Task { [weak self] in
            for await packet in packets {
                self?.handle(packet)
            }
        }
    }

    /// Lights a key from a touch on screen, when no keyboard is connected.
    func touch(_ key: UInt8, down: Bool) {
        if down { touchedKeys.insert(key) } else { touchedKeys.remove(key) }
        let event = KeyEvent(kind: down ? .keyOn : .keyOff, key: key, force: down ? 64 : 0)
        report(event, at: ProcessInfo.processInfo.systemUptime)
        refreshHeld()
    }

    private func connectSources() {
        var names: [String] = []
        var present: Set<MIDIEndpointRef> = []
        for index in 0..<MIDIGetNumberOfSources() {
            let source = MIDIGetSource(index)
            // A virtual source, which another app makes, has no entity. Read real devices only.
            var entity = MIDIEntityRef()
            guard MIDIEndpointGetEntity(source, &entity) == noErr, entity != 0 else { continue }
            present.insert(source)
            if sources[source] == nil {
                sources[source] = Source()
                MIDIPortConnectSource(port, source, UnsafeMutableRawPointer(bitPattern: UInt(source)))
            }
            var name: Unmanaged<CFString>?
            if MIDIObjectGetStringProperty(source, kMIDIPropertyDisplayName, &name) == noErr, let name {
                names.append(name.takeRetainedValue() as String)
            }
        }
        for source in sources.keys where !present.contains(source) {
            // The device went away: none of its keys can still be down.
            MIDIPortDisconnectSource(port, source)
            sources[source] = nil
        }
        deviceNames = names
        refreshHeld()
    }

    private func handle(_ packet: Packet) {
        guard var source = sources[packet.source] else { return }
        let events = source.parser.parse(packet.bytes)
        for event in events {
            switch event.kind {
            case .keyOn:
                source.held.insert(event.key)
            case .keyOff:
                source.held.remove(event.key)
            case .pedal:
                source.pedalDown = event.force >= 64
            }
        }
        sources[packet.source] = source
        for event in events {
            report(event, at: packet.time)
        }
        refreshHeld()
    }

    private func report(_ event: KeyEvent, at time: Double) {
        if event.kind == .keyOn {
            lastKey = event.key
        }
        onEvent?(event, time)
    }

    private func refreshHeld() {
        heldKeys = sources.values.reduce(touchedKeys) { $0.union($1.held) }
        pedalDown = sources.values.contains { $0.pedalDown }
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
