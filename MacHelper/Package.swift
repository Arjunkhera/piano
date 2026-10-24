// swift-tools-version:5.9
import PackageDescription

// piano-listen: the Mac helper of D2 Layer 2. It records what the Mac plays
// and runs Transkun to write the notes as a MIDI file.
let package = Package(
    name: "PianoListen",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "piano-listen", targets: ["PianoListen"]),
    ],
    dependencies: [
        .package(path: "../PianoCore"),
    ],
    targets: [
        .target(name: "ListenOptions"),
        .executableTarget(
            name: "PianoListen",
            dependencies: ["ListenOptions", .product(name: "PianoCore", package: "PianoCore")]
        ),
        .testTarget(name: "ListenOptionsTests", dependencies: ["ListenOptions"]),
    ]
)
