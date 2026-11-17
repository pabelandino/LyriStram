// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "LvoqStreamVideoPipeline",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "LvoqStreamVideoPipeline", targets: ["LvoqStreamVideoPipeline"]),
    ],
    dependencies: [
        .package(path: "../LvoqStreamCore"),
        .package(path: "../LvoqStreamVideoBusNative"),
        .package(url: "https://github.com/stasel/WebRTC.git", from: "150.0.0"),
    ],
    targets: [
        .target(
            name: "LvoqStreamVideoPipeline",
            dependencies: [
                "LvoqStreamCore",
                "LvoqStreamVideoBusNative",
                "WebRTC",
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5),
            ]
        ),
        .testTarget(
            name: "LvoqStreamVideoPipelineTests",
            dependencies: ["LvoqStreamVideoPipeline", "LvoqStreamCore"]
        ),
    ]
)
