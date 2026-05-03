// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "AvicenexAI",
    platforms: [.iOS(.v17), .macOS(.v13)],
    products: [
        .library(name: "AvicenexAI", targets: ["AvicenexAI"])
    ],
    targets: [
        .target(name: "AvicenexAI"),
        .testTarget(name: "AvicenexAITests", dependencies: ["AvicenexAI"])
    ]
)
