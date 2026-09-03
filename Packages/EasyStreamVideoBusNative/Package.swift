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
    targets: [
        .target(
            name: "ESVBNativeCore",
            path: "Sources/ESVBNativeCore",
            publicHeadersPath: "include",
            cxxSettings: [
                .headerSearchPath("include"),
            ]
        ),
        .target(
            name: "EasyStreamVideoBusNative",
            dependencies: ["ESVBNativeCore"],
            path: "Sources/EasyStreamVideoBusNative"
        ),
    ]
)
