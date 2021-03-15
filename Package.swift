// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "hummingbird-mustache",
    products: [
        .library(name: "HummingbirdMustache", targets: ["HummingbirdMustache"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.4.0"),
    ],
    targets: [
        .target(name: "HummingbirdMustache", dependencies: [
            .product(name: "Logging", package: "swift-log"),
        ]),
        .testTarget(name: "HummingbirdMustacheTests", dependencies: ["HummingbirdMustache"]),
    ]
)
