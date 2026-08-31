// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "EasyStreamFacebookLogin",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(name: "EasyStreamFacebookLogin", targets: ["EasyStreamFacebookLogin"]),
    ],
    dependencies: [
        .package(path: "../EasyStreamFacebook"),
        .package(url: "https://github.com/facebook/facebook-ios-sdk", from: "17.0.0"),
    ],
    targets: [
        .target(
            name: "EasyStreamFacebookLogin",
            dependencies: [
                "EasyStreamFacebook",
                .product(name: "FacebookCore", package: "facebook-ios-sdk"),
                .product(name: "FacebookLogin", package: "facebook-ios-sdk"),
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5),
            ]
        ),
    ]
)
