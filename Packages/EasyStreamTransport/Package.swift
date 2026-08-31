// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "EasyStreamTransport",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "EasyStreamTransport", targets: ["EasyStreamTransport"]),
    ],
    dependencies: [
        .package(path: "../EasyStreamCore"),
        .package(url: "https://github.com/stasel/WebRTC.git", from: "150.0.0"),
    ],
    targets: [
        .target(
            name: "EasyStreamTransport",
            dependencies: [
                "EasyStreamCore",
                "WebRTC",
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5),
            ]
        ),
    ]
)
