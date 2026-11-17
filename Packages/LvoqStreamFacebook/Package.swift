// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "LvoqStreamFacebook",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "LvoqStreamFacebook", targets: ["LvoqStreamFacebook"]),
    ],
    dependencies: [
        .package(path: "../LvoqStreamCore"),
    ],
    targets: [
        .target(
            name: "LvoqStreamFacebook",
            dependencies: [
                "LvoqStreamCore",
            ],
            path: "Sources/LvoqStreamFacebook",
            swiftSettings: [
                .swiftLanguageMode(.v5),
            ]
        ),
        .testTarget(
            name: "LvoqStreamFacebookTests",
            dependencies: ["LvoqStreamFacebook", "LvoqStreamCore"]
        ),
    ]
)
