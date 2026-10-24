/// Names of piano keys in scientific pitch notation: key 60 is "C4".
public enum KeyName {
    private static let sharpNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]

    /// The name of a MIDI key, such as "C4" for 60 or "C#4" for 61.
    public static func name(of key: UInt8) -> String {
        let octave = Int(key) / 12 - 1
        return "\(sharpNames[Int(key) % 12])\(octave)"
    }

    /// The name with a hint for a beginner, such as "C4, middle C".
    public static func label(of key: UInt8) -> String {
        key == 60 ? "C4, middle C" : name(of: key)
    }

    /// True for the black keys.
    public static func isBlack(_ key: UInt8) -> Bool {
        [1, 3, 6, 8, 10].contains(Int(key) % 12)
    }
}
