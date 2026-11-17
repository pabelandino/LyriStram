// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "LvoqStreamTransport",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "LvoqStreamTransport", targets: ["LvoqStreamTransport"]),
    ],
    dependencies: [
        .package(path: "../LvoqStreamCore"),
        .package(url: "https://github.com/stasel/WebRTC.git", from: "150.0.0"),
    ],
    targets: [
        .target(
            name: "LvoqStreamTransport",
            dependencies: [
                "LvoqStreamCore",
                "WebRTC",
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5),
            ],
            linkerSettings: [
                .linkedFramework("AVFoundation"),
            ]
        ),
    ]
)
