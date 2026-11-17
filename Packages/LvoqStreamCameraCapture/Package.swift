// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "LvoqStreamCameraCapture",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "LvoqStreamCameraCapture", targets: ["LvoqStreamCameraCapture"]),
    ],
    dependencies: [
        .package(path: "../LvoqStreamCore"),
    ],
    targets: [
        .target(
            name: "LvoqStreamCameraCapture",
            dependencies: ["LvoqStreamCore"]
        ),
    ]
)
