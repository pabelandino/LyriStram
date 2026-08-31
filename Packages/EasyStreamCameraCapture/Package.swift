// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "EasyStreamCameraCapture",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "EasyStreamCameraCapture", targets: ["EasyStreamCameraCapture"]),
    ],
    dependencies: [
        .package(path: "../EasyStreamCore"),
    ],
    targets: [
        .target(
            name: "EasyStreamCameraCapture",
            dependencies: ["EasyStreamCore"]
        ),
    ]
)
