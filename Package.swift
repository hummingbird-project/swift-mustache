// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-mustache",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)],
    products: [
        .executable(name: "mustache", targets: ["CommandLineApp"]),
        .library(name: "Mustache", targets: ["Mustache"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.4.0"),
        .package(url: "https://github.com/jpsim/yams", from: "5.1.0"),
    ],
    targets: [
        .target(name: "Mustache", dependencies: []),
        .executableTarget(
            name: "CommandLineApp",
            dependencies: [
                "Mustache",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Yams", package: "yams"),
            ]
        ),
        .testTarget(name: "MustacheTests", dependencies: ["Mustache"]),
    ]
)
