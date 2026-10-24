/// The keys of an 88-key piano, as MIDI key numbers: A0 is 21, C8 is 108.
public let pianoKeys: ClosedRange<UInt8> = 21...108

/// One message from the keyboard, after `MIDIParser` reads it.
public struct KeyEvent: Equatable, Sendable {
    public enum Kind: Equatable, Sendable {
        case keyOn
        case keyOff
        /// The sustain (damper) pedal. `force` is 0 to 127; 64 and up means down.
        case pedal
    }

    public var kind: Kind
    /// The MIDI key number, 21 to 108. 0 for a pedal event.
    public var key: UInt8
    /// How hard the key was pressed (MIDI velocity), or the pedal value.
    public var force: UInt8
    /// The MIDI channel, 0 to 15.
    public var channel: UInt8

    public init(kind: Kind, key: UInt8, force: UInt8, channel: UInt8 = 0) {
        self.kind = kind
        self.key = key
        self.force = force
        self.channel = channel
    }
}
