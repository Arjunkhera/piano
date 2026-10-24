/// Reads raw MIDI 1.0 bytes into key events.
///
/// It keeps the running status between calls, so a keyboard that leaves out
/// a repeated status byte still reads right. Feed it the bytes of each packet
/// in order.
public struct MIDIParser: Sendable {
    private var status: UInt8?
    private var data: [UInt8] = []

    public init() {}

    /// Reads `bytes` and returns the events they complete, in order.
    public mutating func parse(_ bytes: [UInt8]) -> [KeyEvent] {
        var events: [KeyEvent] = []
        for byte in bytes {
            if byte >= 0xF8 {
                // Real-time messages (clock, active sensing) can come anywhere. Drop them.
                continue
            }
            if byte >= 0xF0 {
                // System common and system exclusive end the running status.
                status = nil
                data.removeAll()
                continue
            }
            if byte >= 0x80 {
                status = byte
                data.removeAll()
                continue
            }
            guard let status else { continue }
            data.append(byte)
            guard data.count == Self.dataLength(for: status) else { continue }
            if let event = Self.event(status: status, data: data) {
                events.append(event)
            }
            data.removeAll()
        }
        return events
    }

    /// Clears the running status, for example after the cable comes out.
    public mutating func reset() {
        status = nil
        data.removeAll()
    }

    private static func dataLength(for status: UInt8) -> Int {
        switch status & 0xF0 {
        case 0xC0, 0xD0: return 1
        default: return 2
        }
    }

    private static func event(status: UInt8, data: [UInt8]) -> KeyEvent? {
        let channel = status & 0x0F
        switch status & 0xF0 {
        case 0x90:
            guard pianoKeys.contains(data[0]) else { return nil }
            // Key on with force 0 means key off.
            let kind: KeyEvent.Kind = data[1] == 0 ? .keyOff : .keyOn
            return KeyEvent(kind: kind, key: data[0], force: data[1], channel: channel)
        case 0x80:
            guard pianoKeys.contains(data[0]) else { return nil }
            return KeyEvent(kind: .keyOff, key: data[0], force: data[1], channel: channel)
        case 0xB0 where data[0] == 64:
            return KeyEvent(kind: .pedal, key: 0, force: data[1], channel: channel)
        default:
            return nil
        }
    }
}
