// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "LvoqStreamAudioPipeline",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "LvoqStreamAudioPipeline", targets: ["LvoqStreamAudioPipeline"]),
    ],
    dependencies: [
        .package(path: "../LvoqStreamCore"),
    ],
    targets: [
        .target(
            name: "LvoqStreamAudioPipeline",
            dependencies: ["LvoqStreamCore"],
            swiftSettings: [
                .swiftLanguageMode(.v5),
            ]
        ),
        .testTarget(
            name: "LvoqStreamAudioPipelineTests",
            dependencies: ["LvoqStreamAudioPipeline", "LvoqStreamCore"]
        ),
    ]
)
