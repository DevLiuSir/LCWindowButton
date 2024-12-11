// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LCWindowButton",
    platforms: [
        .macOS(.v10_15) // 指定支持的 macOS 版本
    ],
    products: [
        .library(
            name: "LCWindowButton",
            targets: ["LCWindowButton"]),
    ],
    targets: [
        .target(
            name: "LCWindowButton"),
        .testTarget(
            name: "LCWindowButtonTests",
            dependencies: ["LCWindowButton"]),
    ]
)
