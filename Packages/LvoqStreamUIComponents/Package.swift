// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "LvoqStreamUIComponents",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "LvoqStreamUIComponents", targets: ["LvoqStreamUIComponents"]),
    ],
    dependencies: [
        .package(path: "../LvoqStreamCore"),
        .package(path: "../LvoqStreamCameraCapture"),
        .package(path: "../LvoqStreamFacebook"),
        .package(path: "../LvoqStreamVideoPipeline"),
        .package(url: "https://github.com/stasel/WebRTC.git", from: "150.0.0"),
    ],
    targets: [
        .target(
            name: "LvoqStreamUIComponents",
            dependencies: [
                "LvoqStreamCore",
                "LvoqStreamCameraCapture",
                "LvoqStreamFacebook",
                "LvoqStreamVideoPipeline",
                "WebRTC",
            ],
            resources: [.process("Resources")]
        ),
    ]
)
