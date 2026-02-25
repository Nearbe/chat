// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MetricsAgent",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "metrics-collector", targets: ["MetricsCLI"]),
        .library(name: "MetricsCollector", targets: ["MetricsCollector"])
    ],
    dependencies: [
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.15.3")
    ],
    targets: [
        .executableTarget(
            name: "MetricsCLI",
            dependencies: [
                .product(name: "SQLite", package: "SQLite.swift"),
                "MetricsCollector"
            ],
            path: "CLI"
        ),
        .target(
            name: "MetricsCollector",
            dependencies: [
                .product(name: "SQLite", package: "SQLite.swift")
            ],
            path: "Lib"
        )
    ]
)
