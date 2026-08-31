// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "EasyStreamAudioPipeline",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "EasyStreamAudioPipeline", targets: ["EasyStreamAudioPipeline"]),
    ],
    dependencies: [
        .package(path: "../EasyStreamCore"),
    ],
    targets: [
        .target(
            name: "EasyStreamAudioPipeline",
            dependencies: ["EasyStreamCore"],
            swiftSettings: [
                .swiftLanguageMode(.v5),
            ]
        ),
        .testTarget(
            name: "EasyStreamAudioPipelineTests",
            dependencies: ["EasyStreamAudioPipeline", "EasyStreamCore"]
        ),
    ]
)
