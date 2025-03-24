// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-mustache",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)],
    products: [
        .library(name: "Mustache", targets: ["Mustache"])
    ],
    dependencies: [],
    targets: [
        .target(name: "Mustache", dependencies: []),
        .testTarget(name: "MustacheTests", dependencies: ["Mustache"]),
    ]
)
