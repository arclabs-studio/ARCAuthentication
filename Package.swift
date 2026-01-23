// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ARCAuthentication",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .tvOS(.v14),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "ARCAuthentication",
            targets: ["ARCAuthentication"]
        ),
    ],
    targets: [
        .target(
            name: "ARCAuthentication",
            path: "Sources"
        ),
        .testTarget(
            name: "ARCAuthenticationTests",
            dependencies: ["ARCAuthentication"],
            path: "Tests"
        )
    ]
)
