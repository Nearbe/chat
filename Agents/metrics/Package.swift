// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MetricsAgent",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "metrics-collector", targets: ["MetricsCLI"])
    ],
    dependencies: [
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.15.3")
    ],
    targets: [
        .executableTarget(
            name: "MetricsCLI",
            dependencies: ["MetricsCore", "SQLite"],
            path: "CLI"
        ),
        .target(
            name: "MetricsCore",
            dependencies: ["SQLite"],
            path: "."
        )
    ]
)
