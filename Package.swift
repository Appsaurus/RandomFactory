// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RandomFactory",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(name: "RandomFactory", targets: ["RandomFactory"])
    ],
    dependencies: [
        .package(url: "https://github.com/vadymmarkov/Fakery", .exact("5.1.0")),
        .package(url: "https://github.com/Appsaurus/Avatars", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/Appsaurus/PlaceholderImages", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/Appsaurus/CodableExtensions",  .upToNextMajor(from: "1.0.0")),
    ],
    targets: [
        .target(
            name: "RandomFactory",
            dependencies: [
                .product(name: "Fakery", package: "Fakery"),
                .product(name: "Avatars", package: "Avatars"),
                .product(name: "PlaceholderImages", package: "PlaceholderImages"),
                .product(name: "CodableExtensions", package: "CodableExtensions")
            ], path: "./Sources/Shared"),
        .testTarget(name: "RandomFactoryTests", dependencies: [
            .target(name: "RandomFactory")
        ], path: "./RandomFactoryTests/Shared")
    ]
)
