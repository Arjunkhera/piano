import Foundation

/// Opens a compressed MusicXML file (.mxl). An .mxl file is a zip archive.
/// The file META-INF/container.xml names the score inside it.
///
/// Foundation has no zip reader on Linux, so this file holds a small one:
/// stored and deflate entries only, which is what MusicXML apps write.
enum MXLArchive {
    /// The largest score it will unpack, so a hostile file can not fill memory.
    static let maxScoreSize = 64 << 20

    struct Entry {
        var name: String
        var method: UInt16
        var compressedSize: Int
        var size: Int
        var localHeader: Int
    }

    static func score(in data: Data) throws -> Data {
        let bytes = [UInt8](data)
        let entries = try centralDirectory(bytes)
        let names = entries.map(\.name)
        var target: String?
        if let container = entries.first(where: { $0.name == "META-INF/container.xml" }) {
            let xml = String(decoding: try unpack(container, from: bytes), as: UTF8.self)
            target = rootFile(in: xml)
        }
        if target == nil || !names.contains(target!) {
            target = names.first {
                !$0.hasPrefix("META-INF/") && ($0.hasSuffix(".xml") || $0.hasSuffix(".musicxml"))
            }
        }
        guard let target, let entry = entries.first(where: { $0.name == target }) else {
            throw SongImportError.damaged("the .mxl file holds no score")
        }
        return Data(try unpack(entry, from: bytes))
    }

    /// The `full-path` of the first `rootfile` in container.xml.
    static func rootFile(in xml: String) -> String? {
        guard let tag = xml.range(of: "<rootfile") else { return nil }
        let rest = xml[tag.upperBound...]
        guard let key = rest.range(of: "full-path=") else { return nil }
        let afterKey = rest[key.upperBound...]
        guard let quote = afterKey.first, quote == "\"" || quote == "'" else { return nil }
        let value = afterKey.dropFirst()
        guard let end = value.firstIndex(of: quote) else { return nil }
        return String(value[..<end])
    }

    static func centralDirectory(_ bytes: [UInt8]) throws -> [Entry] {
        // The end record is at least 22 bytes, plus a comment of up to 64 KB.
        let lowest = max(0, bytes.count - 22 - 0xFFFF)
        var end = bytes.count - 22
        while end >= lowest, le32(bytes, end) != 0x0605_4B50 { end -= 1 }
        guard end >= lowest, end >= 0 else { throw SongImportError.damaged("the .mxl file has no zip directory") }
        let count = Int(le16(bytes, end + 10))
        var offset = Int(le32(bytes, end + 16))
        var entries: [Entry] = []
        for _ in 0..<count {
            guard offset + 46 <= bytes.count, le32(bytes, offset) == 0x0201_4B50 else {
                throw SongImportError.damaged("the zip directory is broken")
            }
            let nameLength = Int(le16(bytes, offset + 28))
            let extraLength = Int(le16(bytes, offset + 30))
            let commentLength = Int(le16(bytes, offset + 32))
            guard offset + 46 + nameLength <= bytes.count else {
                throw SongImportError.damaged("the zip directory is broken")
            }
            entries.append(Entry(
                name: String(decoding: bytes[offset + 46..<offset + 46 + nameLength], as: UTF8.self),
                method: le16(bytes, offset + 10),
                compressedSize: Int(le32(bytes, offset + 20)),
                size: Int(le32(bytes, offset + 24)),
                localHeader: Int(le32(bytes, offset + 42))
            ))
            offset += 46 + nameLength + extraLength + commentLength
        }
        return entries
    }

    static func unpack(_ entry: Entry, from bytes: [UInt8]) throws -> [UInt8] {
        let header = entry.localHeader
        guard header + 30 <= bytes.count, le32(bytes, header) == 0x0403_4B50 else {
            throw SongImportError.damaged("a zip entry is broken")
        }
        let start = header + 30 + Int(le16(bytes, header + 26)) + Int(le16(bytes, header + 28))
        guard entry.compressedSize >= 0, start + entry.compressedSize <= bytes.count else {
            throw SongImportError.damaged("a zip entry is cut short")
        }
        guard entry.size <= maxScoreSize else { throw SongImportError.unsupported("the score is too large") }
        let body = Array(bytes[start..<start + entry.compressedSize])
        switch entry.method {
        case 0: return body
        case 8: return try Inflater.inflate(body, limit: maxScoreSize)
        default: throw SongImportError.unsupported("zip method \(entry.method)")
        }
    }

    static func le16(_ bytes: [UInt8], _ at: Int) -> UInt16 {
        guard at >= 0, at + 2 <= bytes.count else { return 0 }
        return UInt16(bytes[at]) | UInt16(bytes[at + 1]) << 8
    }

    static func le32(_ bytes: [UInt8], _ at: Int) -> UInt32 {
        guard at >= 0, at + 4 <= bytes.count else { return 0 }
        return UInt32(le16(bytes, at)) | UInt32(le16(bytes, at + 2)) << 16
    }
}

/// Raw deflate (RFC 1951) decoder, after Mark Adler's puff.c.
struct Inflater {
    private let input: [UInt8]
    private var position = 0
    private var bitBuffer: UInt32 = 0
    private var bitCount = 0
    private var output: [UInt8] = []
    private let limit: Int

    static func inflate(_ input: [UInt8], limit: Int) throws -> [UInt8] {
        var inflater = Inflater(input: input, limit: limit)
        try inflater.run()
        return inflater.output
    }

    private init(input: [UInt8], limit: Int) {
        self.input = input
        self.limit = limit
    }

    private static func broken() -> SongImportError {
        .damaged("the compressed data is broken")
    }

    private mutating func bits(_ count: Int) throws -> Int {
        while bitCount < count {
            guard position < input.count else { throw Self.broken() }
            bitBuffer |= UInt32(input[position]) << UInt32(bitCount)
            position += 1
            bitCount += 8
        }
        let value = Int(bitBuffer & ((1 << UInt32(count)) - 1))
        bitBuffer >>= UInt32(count)
        bitCount -= count
        return value
    }

    private mutating func run() throws {
        var last = false
        while !last {
            last = try bits(1) == 1
            switch try bits(2) {
            case 0: try stored()
            case 1: try codes(literal: Self.fixedLiteral, distance: Self.fixedDistance)
            case 2:
                let (literal, distance) = try dynamicTables()
                try codes(literal: literal, distance: distance)
            default: throw Self.broken()
            }
        }
    }

    private mutating func stored() throws {
        bitBuffer = 0
        bitCount = 0
        guard position + 4 <= input.count else { throw Self.broken() }
        let length = Int(input[position]) | Int(input[position + 1]) << 8
        let check = Int(input[position + 2]) | Int(input[position + 3]) << 8
        position += 4
        guard length == ~check & 0xFFFF, position + length <= input.count else { throw Self.broken() }
        guard output.count + length <= limit else { throw SongImportError.unsupported("the score is too large") }
        output.append(contentsOf: input[position..<position + length])
        position += length
    }

    struct Huffman {
        var counts = [Int](repeating: 0, count: 16)
        var symbols: [Int]

        init(lengths: [Int]) {
            symbols = [Int](repeating: 0, count: lengths.count)
            for length in lengths { counts[length] += 1 }
            counts[0] = 0
            var offsets = [Int](repeating: 0, count: 16)
            for length in 1..<16 { offsets[length] = offsets[length - 1] + counts[length - 1] }
            for (symbol, length) in lengths.enumerated() where length != 0 {
                symbols[offsets[length]] = symbol
                offsets[length] += 1
            }
        }
    }

    private mutating func decode(_ table: Huffman) throws -> Int {
        var code = 0
        var first = 0
        var index = 0
        for length in 1..<16 {
            code |= try bits(1)
            let count = table.counts[length]
            if code - count < first { return table.symbols[index + code - first] }
            index += count
            first = (first + count) << 1
            code <<= 1
        }
        throw Self.broken()
    }

    private static let lengthBase = [3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 15, 17, 19, 23, 27, 31,
                                     35, 43, 51, 59, 67, 83, 99, 115, 131, 163, 195, 227, 258]
    private static let lengthExtra = [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2,
                                      3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 0]
    private static let distanceBase = [1, 2, 3, 4, 5, 7, 9, 13, 17, 25, 33, 49, 65, 97, 129, 193,
                                       257, 385, 513, 769, 1025, 1537, 2049, 3073, 4097, 6145,
                                       8193, 12289, 16385, 24577]
    private static let distanceExtra = [0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6,
                                        7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12, 12, 13, 13]

    private static let fixedLiteral = Huffman(lengths:
        [Int](repeating: 8, count: 144) + [Int](repeating: 9, count: 112)
            + [Int](repeating: 7, count: 24) + [Int](repeating: 8, count: 8))
    private static let fixedDistance = Huffman(lengths: [Int](repeating: 5, count: 30))

    private mutating func codes(literal: Huffman, distance: Huffman) throws {
        while true {
            let symbol = try decode(literal)
            if symbol < 256 {
                guard output.count < limit else { throw SongImportError.unsupported("the score is too large") }
                output.append(UInt8(symbol))
            } else if symbol == 256 {
                return
            } else {
                let lengthIndex = symbol - 257
                guard lengthIndex < Self.lengthBase.count else { throw Self.broken() }
                let length = try Self.lengthBase[lengthIndex] + bits(Self.lengthExtra[lengthIndex])
                let distanceIndex = try decode(distance)
                guard distanceIndex < Self.distanceBase.count else { throw Self.broken() }
                let back = try Self.distanceBase[distanceIndex] + bits(Self.distanceExtra[distanceIndex])
                guard back <= output.count else { throw Self.broken() }
                guard output.count + length <= limit else { throw SongImportError.unsupported("the score is too large") }
                let from = output.count - back
                for offset in 0..<length {
                    output.append(output[from + offset])
                }
            }
        }
    }

    private mutating func dynamicTables() throws -> (Huffman, Huffman) {
        let literalCount = try bits(5) + 257
        let distanceCount = try bits(5) + 1
        let codeCount = try bits(4) + 4
        guard literalCount <= 286, distanceCount <= 30 else { throw Self.broken() }
        let order = [16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15]
        var codeLengths = [Int](repeating: 0, count: 19)
        for index in 0..<codeCount {
            codeLengths[order[index]] = try bits(3)
        }
        let codeTable = Huffman(lengths: codeLengths)
        var lengths: [Int] = []
        while lengths.count < literalCount + distanceCount {
            let symbol = try decode(codeTable)
            switch symbol {
            case 0..<16:
                lengths.append(symbol)
            case 16:
                guard let previous = lengths.last else { throw Self.broken() }
                lengths += try [Int](repeating: previous, count: 3 + bits(2))
            case 17:
                lengths += try [Int](repeating: 0, count: 3 + bits(3))
            default:
                lengths += try [Int](repeating: 0, count: 11 + bits(7))
            }
        }
        guard lengths.count == literalCount + distanceCount, lengths[256] != 0 else { throw Self.broken() }
        return (
            Huffman(lengths: Array(lengths[..<literalCount])),
            Huffman(lengths: Array(lengths[literalCount...]))
        )
    }
}
