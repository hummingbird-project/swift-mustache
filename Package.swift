// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "hummingbird-mustache",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)],
    products: [
        .library(name: "HummingbirdMustache", targets: ["HummingbirdMustache"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "HummingbirdMustache", dependencies: []),
        .testTarget(name: "HummingbirdMustacheTests", dependencies: ["HummingbirdMustache"]),
    ]
)
