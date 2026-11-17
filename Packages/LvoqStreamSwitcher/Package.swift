// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "LvoqStreamSwitcher",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "LvoqStreamSwitcher", targets: ["LvoqStreamSwitcher"]),
    ],
    dependencies: [
        .package(path: "../LvoqStreamCore"),
    ],
    targets: [
        .target(
            name: "LvoqStreamSwitcher",
            dependencies: ["LvoqStreamCore"]
        ),
        .testTarget(
            name: "LvoqStreamSwitcherTests",
            dependencies: ["LvoqStreamSwitcher", "LvoqStreamCore"]
        ),
    ]
)
