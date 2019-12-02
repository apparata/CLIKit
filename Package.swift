// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "CLIKit",
    platforms: [.macOS(.v10_14)],
    products: [
        .library(name: "CLIKit", targets: ["CLIKit"]),
    ],
    targets: [
        .target(
            name: "CLIKit",
            dependencies: [],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
                .define("RELEASE", .when(configuration: .release)),
                .define("SWIFT_PACKAGE")
            ]
        ),
        .testTarget(
            name: "CLIKitTests",
            dependencies: ["CLIKit"],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
                .define("RELEASE", .when(configuration: .release)),
                .define("SWIFT_PACKAGE")
            ]
        ),
    ]
)
