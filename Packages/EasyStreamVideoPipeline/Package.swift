// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "EasyStreamVideoPipeline",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "EasyStreamVideoPipeline", targets: ["EasyStreamVideoPipeline"]),
    ],
    dependencies: [
        .package(path: "../EasyStreamCore"),
        .package(url: "https://github.com/stasel/WebRTC.git", from: "150.0.0"),
    ],
    targets: [
        .target(
            name: "EasyStreamVideoPipeline",
            dependencies: [
                "EasyStreamCore",
                "WebRTC",
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5),
            ]
        ),
        .testTarget(
            name: "EasyStreamVideoPipelineTests",
            dependencies: ["EasyStreamVideoPipeline", "EasyStreamCore"]
        ),
    ]
)
