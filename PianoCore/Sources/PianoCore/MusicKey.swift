import Foundation

/// The key of a song, such as C major or A minor.
public struct MusicKey: Equatable, Hashable, Codable, Sendable {
    public enum Mode: String, Codable, Sendable {
        case major
        case minor
    }

    /// The key note as a pitch class: 0 is C, 1 is C#, up to 11 for B.
    public var tonic: Int
    public var mode: Mode

    public init(tonic: Int, mode: Mode) {
        self.tonic = ((tonic % 12) + 12) % 12
        self.mode = mode
    }

    /// The sharps or flats in the key signature, 0 to 6. F# major counts 6.
    public var accidentals: Int {
        let major = mode == .major ? tonic : (tonic + 3) % 12
        return [0, 5, 2, 3, 4, 1, 6, 1, 4, 3, 2, 5][major]
    }

    /// A name such as "Eb major" or "F# minor".
    public var name: String {
        let majorNames = ["C", "Db", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B"]
        let minorNames = ["C", "C#", "D", "Eb", "E", "F", "F#", "G", "G#", "A", "Bb", "B"]
        let names = mode == .major ? majorNames : minorNames
        return "\(names[tonic]) \(mode.rawValue)"
    }

    /// The same key, moved up by `shift` keys (down when negative).
    public func moved(by shift: Int) -> MusicKey {
        MusicKey(tonic: tonic + shift, mode: mode)
    }

    // The Krumhansl-Kessler key profiles, from C.
    private static let majorProfile = [6.35, 2.23, 3.48, 2.33, 4.38, 4.09, 2.52, 5.19, 2.39, 3.66, 2.29, 2.88]
    private static let minorProfile = [6.33, 2.68, 3.52, 5.38, 2.60, 3.53, 2.54, 4.75, 3.98, 2.69, 3.34, 3.17]

    /// Finds the key of a list of notes. Each note counts by its length. The
    /// key whose Krumhansl-Kessler profile fits best wins. With no notes, or
    /// with every pitch class equal, the answer is C major.
    public static func find(in notes: [Note]) -> MusicKey {
        var weights = [Double](repeating: 0, count: 12)
        for note in notes where note.length > 0 {
            weights[Int(note.key) % 12] += note.length
        }
        var best = MusicKey(tonic: 0, mode: .major)
        var bestFit = -Double.infinity
        for mode in [Mode.major, .minor] {
            let profile = mode == .major ? majorProfile : minorProfile
            for tonic in 0..<12 {
                let rotated = (0..<12).map { weights[(tonic + $0) % 12] }
                let fit = correlation(rotated, profile)
                if fit > bestFit {
                    bestFit = fit
                    best = MusicKey(tonic: tonic, mode: mode)
                }
            }
        }
        return best
    }

    private static func correlation(_ a: [Double], _ b: [Double]) -> Double {
        let meanA = a.reduce(0, +) / Double(a.count)
        let meanB = b.reduce(0, +) / Double(b.count)
        var top = 0.0, sumA = 0.0, sumB = 0.0
        for i in a.indices {
            top += (a[i] - meanA) * (b[i] - meanB)
            sumA += (a[i] - meanA) * (a[i] - meanA)
            sumB += (b[i] - meanB) * (b[i] - meanB)
        }
        let bottom = (sumA * sumB).squareRoot()
        return bottom > 0 ? top / bottom : -Double.infinity
    }
}
