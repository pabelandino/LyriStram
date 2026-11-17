// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "LvoqStreamVideoBusNative",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "LvoqStreamVideoBusNative", targets: ["LvoqStreamVideoBusNative"]),
    ],
    dependencies: [
        .package(path: "../LvoqStreamCore"),
    ],
    targets: [
        .target(
            name: "ESVBNativeCore",
            path: "Sources/ESVBNativeCore",
            publicHeadersPath: "include",
            cxxSettings: [
                .headerSearchPath("include"),
            ],
            linkerSettings: [
                .linkedFramework("CoreVideo"),
            ]
        ),
        .target(
            name: "LvoqStreamVideoBusNative",
            dependencies: [
                "ESVBNativeCore",
                "LvoqStreamCore",
            ],
            path: "Sources/LvoqStreamVideoBusNative"
        ),
    ]
)
