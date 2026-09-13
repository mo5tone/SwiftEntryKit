import ProjectDescription

let project = Project(
    name: "SwiftEntryKitDemo",
    packages: [
        .local(path: "../")
    ],
    targets: [
        .target(
            name: "SwiftEntryKitDemo",
            destinations: .iOS,
            product: .app,
            bundleId: "com.huri.SwiftEntryKitDemo",
            deploymentTargets: .iOS("14.0"),
            infoPlist: .file(path: "SwiftEntryKit/DemoAppInfo.plist"),
            sources: ["SwiftEntryKit/**/*.swift"],
            resources: [
                "SwiftEntryKit/Images.xcassets",
                "SwiftEntryKit/Base.lproj/**"
            ],
            dependencies: [
                .package(product: "SwiftEntryKit", type: .runtime)
            ]
        )
    ]
)
