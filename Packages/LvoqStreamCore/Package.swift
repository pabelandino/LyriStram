// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "LvoqStreamCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "LvoqStreamCore", targets: ["LvoqStreamCore"]),
    ],
    targets: [
        .target(name: "LvoqStreamCore"),
        .testTarget(
            name: "LvoqStreamCoreTests",
            dependencies: ["LvoqStreamCore"]
        ),
    ]
)
