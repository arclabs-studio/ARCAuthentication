// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ARCAuthentication",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10),
        .tvOS(.v17),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "ARCAuthCore",
            targets: ["ARCAuthCore"]
        ),
        .library(
            name: "ARCAuthClient",
            targets: ["ARCAuthClient"]
        ),
        .library(
            name: "ARCAuthentication",
            targets: ["ARCAuthCore", "ARCAuthClient"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/arclabs-studio/ARCLogger.git", from: "1.0.0"),
        .package(url: "https://github.com/arclabs-studio/ARCStorage.git", from: "1.0.0")
    ],
    targets: [
        // MARK: - Core (Shared DTOs)

        .target(
            name: "ARCAuthCore",
            dependencies: [],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "ARCAuthCoreTests",
            dependencies: ["ARCAuthCore"]
        ),

        // MARK: - Client (iOS)

        .target(
            name: "ARCAuthClient",
            dependencies: [
                "ARCAuthCore",
                .product(name: "ARCLogger", package: "ARCLogger"),
                .product(name: "ARCStorage", package: "ARCStorage")
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "ARCAuthClientTests",
            dependencies: [
                "ARCAuthClient",
                "ARCAuthCore"
            ]
        )
    ]
)
