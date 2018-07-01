// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "RandomFactory",
	products: [
		.library(name: "RandomFactory", targets: ["RandomFactory"])
	],
	dependencies: [
		.package(url: "https://github.com/Appsaurus/Fakery", .upToNextMajor(from: "3.3.8")),
		.package(url: "https://github.com/Appsaurus/Avatars", .upToNextMajor(from: "1.0.0")),
		.package(url: "https://github.com/Appsaurus/PlaceholderImages", .upToNextMajor(from: "1.0.0")),
		.package(url: "https://github.com/Appsaurus/CodableExtensions",  .upToNextMajor(from: "1.0.0")),
		.package(url: "https://github.com/Appsaurus/SwiftTestUtils",  .upToNextMajor(from: "1.0.0"))
	],
	targets: [
		.target(name: "RandomFactory", dependencies: ["Fakery", "Avatars", "PlaceholderImages", "CodableExtensions"], path: "./Sources/Shared"),
		.testTarget(name: "RandomFactoryTests", dependencies: ["RandomFactory", "SwiftTestUtils"], path: "./RandomFactoryTests/Shared")
	]
)
