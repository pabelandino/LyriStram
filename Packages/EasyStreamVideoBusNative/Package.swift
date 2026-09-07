// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "EasyStreamVideoBusNative",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "EasyStreamVideoBusNative", targets: ["EasyStreamVideoBusNative"]),
    ],
    dependencies: [
        .package(path: "../EasyStreamCore"),
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
            name: "EasyStreamVideoBusNative",
            dependencies: [
                "ESVBNativeCore",
                "EasyStreamCore",
            ],
            path: "Sources/EasyStreamVideoBusNative"
        ),
    ]
)
