// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "LvoqStreamStreaming",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "LvoqStreamStreaming", targets: ["LvoqStreamStreaming"]),
    ],
    dependencies: [
        .package(path: "../LvoqStreamCore"),
    ],
    targets: [
        .target(
            name: "LvoqStreamStreaming",
            dependencies: ["LvoqStreamCore"],
            swiftSettings: [
                .swiftLanguageMode(.v5),
            ]
        ),
        .testTarget(
            name: "LvoqStreamStreamingTests",
            dependencies: ["LvoqStreamStreaming", "LvoqStreamCore"]
        ),
    ]
)
