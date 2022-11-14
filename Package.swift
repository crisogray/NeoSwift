// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NeoSwift",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "NeoSwift",
            targets: ["NeoSwift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/leif-ibsen/BigInt", from: "1.4.0"),
        .package(url: "https://github.com/leif-ibsen/SwiftECC", from: "3.4.1"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift", from: "1.6.0"),
    ],
    targets: [
        .target(
            name: "NeoSwift",
            dependencies: ["BigInt", "CryptoSwift", "SwiftECC"]),
        .testTarget(
            name: "NeoSwiftTests",
            dependencies: ["NeoSwift"]),
    ]
)
