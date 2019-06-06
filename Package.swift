// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "RandomFactory",
    platforms: [
        .macOS(.v10_12)
    ],
	products: [
		.library(name: "RandomFactory", targets: ["RandomFactory"])
	],
	dependencies: [
		.package(url: "https://github.com/Appsaurus/Fakery", from: "3.4.0"),
		.package(url: "https://github.com/Appsaurus/Avatars", from: "1.0.0"),
		.package(url: "https://github.com/Appsaurus/PlaceholderImages", .upToNextMajor(from: "1.0.0")),
		.package(url: "https://github.com/Appsaurus/CodableExtensions",  .upToNextMajor(from: "1.0.0")),
		.package(url: "https://github.com/Appsaurus/SwiftTestUtils",  .upToNextMajor(from: "1.0.0"))
	],
	targets: [
		.target(name: "RandomFactory", dependencies: ["Fakery", "Avatars", "PlaceholderImages", "CodableExtensions"], path: "./Sources/Shared"),
		.testTarget(name: "RandomFactoryTests", dependencies: ["RandomFactory", "SwiftTestUtils"], path: "./RandomFactoryTests/Shared")
	]
)
