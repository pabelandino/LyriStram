// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "EasyStreamUIComponents",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "EasyStreamUIComponents", targets: ["EasyStreamUIComponents"]),
    ],
    dependencies: [
        .package(path: "../EasyStreamCore"),
        .package(path: "../EasyStreamCameraCapture"),
        .package(path: "../EasyStreamFacebook"),
        .package(path: "../EasyStreamVideoPipeline"),
        .package(url: "https://github.com/stasel/WebRTC.git", from: "150.0.0"),
    ],
    targets: [
        .target(
            name: "EasyStreamUIComponents",
            dependencies: [
                "EasyStreamCore",
                "EasyStreamCameraCapture",
                "EasyStreamFacebook",
                "EasyStreamVideoPipeline",
                "WebRTC",
            ]
        ),
    ]
)
