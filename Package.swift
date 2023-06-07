// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NeoSwift",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(name: "NeoSwift",
                 targets: ["NeoSwift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/leif-ibsen/BigInt", from: "1.4.0"),
        .package(url: "https://github.com/leif-ibsen/SwiftECC", from: "3.4.1"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift", from: "1.6.0"),
        .package(url: "https://github.com/greymass/swift-scrypt.git", from: "1.0.0"),
        .package(url: "https://github.com/pengpengliu/BIP39", from: "1.0.1"),
    ],
    targets: [
        .target(name: "NeoSwift",
                dependencies: ["BigInt", "CryptoSwift", "SwiftECC", "BIP39",
                               .product(name: "Scrypt", package: "swift-scrypt")]),
        .testTarget(name: "NeoSwiftTests",
                    dependencies: ["NeoSwift", "BigInt", "SwiftECC"],
                    resources: [.process("unit/resources/account.json"),
                                .process("unit/resources/multiSigAccount.json"),
                                .process("unit/resources/wallet.json"),
                                .process("unit/resources/wallet_noDefaultAccount.json")]),
    ]
)
