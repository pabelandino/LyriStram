// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "EasyStreamCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "EasyStreamCore", targets: ["EasyStreamCore"]),
    ],
    targets: [
        .target(name: "EasyStreamCore"),
        .testTarget(
            name: "EasyStreamCoreTests",
            dependencies: ["EasyStreamCore"]
        ),
    ]
)
