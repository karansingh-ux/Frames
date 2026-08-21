// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Frames",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "Frames", targets: ["Frames"]),
        .executable(name: "FramesVerification", targets: ["FramesVerification"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "FramesCore",
            dependencies: [],
            path: "Sources/FramesCore"
        ),
        .executableTarget(
            name: "Frames",
            dependencies: ["FramesCore"],
            path: "Sources/FramesApp"
        ),
        .executableTarget(
            name: "FramesVerification",
            dependencies: ["FramesCore"],
            path: "Sources/FramesVerification"
        )
    ]
)
