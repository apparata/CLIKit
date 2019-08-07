// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "CLIKit",
    platforms: [.macOS(.v10_14)],
    products: [
        .library(name: "CLIKit", targets: ["CLIKit"]),
    ],
    targets: [
        .target(name: "CLIKit", dependencies: []),
        .testTarget(name: "CLIKitTests", dependencies: ["CLIKit"]),
    ]
)
