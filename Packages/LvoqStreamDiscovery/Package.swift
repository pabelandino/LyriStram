// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "LvoqStreamDiscovery",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "LvoqStreamDiscovery", targets: ["LvoqStreamDiscovery"]),
    ],
    dependencies: [
        .package(path: "../LvoqStreamCore"),
    ],
    targets: [
        .target(
            name: "LvoqStreamDiscovery",
            dependencies: ["LvoqStreamCore"]
        ),
        .testTarget(
            name: "LvoqStreamDiscoveryTests",
            dependencies: ["LvoqStreamDiscovery", "LvoqStreamCore"]
        ),
    ]
)
