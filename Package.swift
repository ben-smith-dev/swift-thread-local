// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-thread-local",
    products: [
        .library(
            name: "ThreadLocal",
            targets: ["ThreadLocal"]
        )
    ],
    targets: [
        .target(
            name: "ThreadLocal",
            resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
        .testTarget(
            name: "ThreadLocalTests",
            dependencies: [.target(name: "ThreadLocal")]
        )
    ]
)

// MARK: Swift Upcoming Features

let swiftUpcomingFeatures: [SwiftSetting] = [
    // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0335-existential-any.md
    .enableUpcomingFeature("ExistentialAny"),

    // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0409-access-level-on-imports.md
    .enableUpcomingFeature("InternalImportsByDefault"),

    // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0444-member-import-visibility.md
    .enableUpcomingFeature("MemberImportVisibility"),

    // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0446-non-escapable.md
    .enableUpcomingFeature("NonescapableTypes"),

    // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0461-async-function-isolation.md
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),

    // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0470-isolated-conformances.md
    .enableUpcomingFeature("InferIsolatedConformances"),

    // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0481-weak-let.md
    .enableUpcomingFeature("ImmutableWeakCaptures"),
]

for target in package.targets where [.regular, .test, .executable, .macro].contains(target.type) {
    target.swiftSettings = (target.swiftSettings ?? []) + swiftUpcomingFeatures
}
