// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "hummingbird-mustache",
    products: [
        .library(name: "HummingbirdMustache", targets: ["HummingbirdMustache"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "HummingbirdMustache", dependencies: []),
        .testTarget(name: "HummingbirdMustacheTests", dependencies: ["HummingbirdMustache"]),
    ]
)
