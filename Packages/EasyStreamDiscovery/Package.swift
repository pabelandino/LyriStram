// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "EasyStreamDiscovery",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "EasyStreamDiscovery", targets: ["EasyStreamDiscovery"]),
    ],
    dependencies: [
        .package(path: "../EasyStreamCore"),
    ],
    targets: [
        .target(
            name: "EasyStreamDiscovery",
            dependencies: ["EasyStreamCore"]
        ),
        .testTarget(
            name: "EasyStreamDiscoveryTests",
            dependencies: ["EasyStreamDiscovery", "EasyStreamCore"]
        ),
    ]
)
