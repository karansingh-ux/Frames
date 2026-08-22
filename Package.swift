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
    dependencies: [
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.6.0")
    ],
    targets: [
        .target(
            name: "FramesCore",
            dependencies: [
                .product(name: "Sparkle", package: "Sparkle")
            ],
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
