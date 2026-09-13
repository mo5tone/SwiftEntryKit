// swift-tools-version:5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SwiftEntryKit",
  platforms: [
    .iOS(.v14)
  ],
  products: [
    .library(name: "SwiftEntryKit", targets: ["SwiftEntryKit"])
  ],
  targets: [
    .target(
      name: "SwiftEntryKit",
      path: "Source",
      swiftSettings: [
        .enableUpcomingFeature("StrictConcurrency")
      ]
    )
  ]
)
