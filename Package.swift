// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ARCAuthentication",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "ARCAuthentication",
            targets: ["ARCAuthentication"]),
        .library(
            name: "ARCAuthGoogle",
            targets: ["ARCAuthGoogle"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/google/GoogleSignIn-iOS.git",
            from: "8.0.0")
    ],
    targets: [
        // MARK: - Core (Credential Providers)

        .target(
            name: "ARCAuthentication",
            dependencies: []),
        .testTarget(
            name: "ARCAuthenticationTests",
            dependencies: ["ARCAuthentication"]),

        // MARK: - Google (Google Sign-In)

        .target(
            name: "ARCAuthGoogle",
            dependencies: [
                "ARCAuthentication",
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS")
            ]),
        .testTarget(
            name: "ARCAuthGoogleTests",
            dependencies: ["ARCAuthGoogle"])
    ],
    swiftLanguageModes: [.v6])
