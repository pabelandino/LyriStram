// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "EasyStreamSwitcher",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "EasyStreamSwitcher", targets: ["EasyStreamSwitcher"]),
    ],
    dependencies: [
        .package(path: "../EasyStreamCore"),
    ],
    targets: [
        .target(
            name: "EasyStreamSwitcher",
            dependencies: ["EasyStreamCore"]
        ),
        .testTarget(
            name: "EasyStreamSwitcherTests",
            dependencies: ["EasyStreamSwitcher", "EasyStreamCore"]
        ),
    ]
)
