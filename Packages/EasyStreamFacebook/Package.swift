// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "EasyStreamFacebook",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "EasyStreamFacebook", targets: ["EasyStreamFacebook"]),
    ],
    dependencies: [
        .package(path: "../EasyStreamCore"),
    ],
    targets: [
        .target(
            name: "EasyStreamFacebook",
            dependencies: [
                "EasyStreamCore",
            ],
            path: "Sources/EasyStreamFacebook",
            swiftSettings: [
                .swiftLanguageMode(.v5),
            ]
        ),
        .testTarget(
            name: "EasyStreamFacebookTests",
            dependencies: ["EasyStreamFacebook", "EasyStreamCore"]
        ),
    ]
)
