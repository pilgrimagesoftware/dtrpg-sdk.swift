// swift-tools-version: 6.2
//
// DriveThruRPG SDK
// Copyright (c) 2026 Pilgrimage Softwware
// Licensed under the MIT License
//

import PackageDescription

let package = Package(
    name: "DriveThruRPGSDK",
platforms: [
        .macOS(.v15),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "DriveThruRPGSDK",
            targets: ["SDK"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.10.0"),
        .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.9.0"),
                .package(url: "https://github.com/apple/swift-openapi-urlsession", from: "1.0.0"),

    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SDK",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession"),
            ],
            swiftSettings: swiftSettings,
            plugins: [
                .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator")
            ]
        ),
        .testTarget(
            name: "SDKTests",
            dependencies: ["SDK"],
            swiftSettings: swiftSettings
        ),
    ]
)

var swiftSettings: [SwiftSetting] {
    [
        .enableUpcomingFeature("ExistentialAny"),
        .swiftLanguageMode(.v5),
    ]
}
