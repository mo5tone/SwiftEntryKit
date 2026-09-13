// swift-tools-version:5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftEntryKit",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(name: "SwiftEntryKit", targets: ["SwiftEntryKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.18.0"),
    ],
    targets: [
        .target(
            name: "SwiftEntryKit",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]
        ),
        .testTarget(
            name: "SwiftEntryKitTests",
            dependencies: [
                "SwiftEntryKit",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ],
            resources: [
                .copy("__Snapshots__"),
            ]
        ),
    ]
)
