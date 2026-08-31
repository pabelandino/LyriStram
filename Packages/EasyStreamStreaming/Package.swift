// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "EasyStreamStreaming",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "EasyStreamStreaming", targets: ["EasyStreamStreaming"]),
    ],
    dependencies: [
        .package(path: "../EasyStreamCore"),
    ],
    targets: [
        .target(
            name: "EasyStreamStreaming",
            dependencies: ["EasyStreamCore"],
            swiftSettings: [
                .swiftLanguageMode(.v5),
            ]
        ),
        .testTarget(
            name: "EasyStreamStreamingTests",
            dependencies: ["EasyStreamStreaming", "EasyStreamCore"]
        ),
    ]
)
