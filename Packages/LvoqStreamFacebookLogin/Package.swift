// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "LvoqStreamFacebookLogin",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(name: "LvoqStreamFacebookLogin", targets: ["LvoqStreamFacebookLogin"]),
    ],
    dependencies: [
        .package(path: "../LvoqStreamFacebook"),
        .package(url: "https://github.com/facebook/facebook-ios-sdk", from: "17.0.0"),
    ],
    targets: [
        .target(
            name: "LvoqStreamFacebookLogin",
            dependencies: [
                "LvoqStreamFacebook",
                .product(name: "FacebookCore", package: "facebook-ios-sdk"),
                .product(name: "FacebookLogin", package: "facebook-ios-sdk"),
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5),
            ]
        ),
    ]
)
