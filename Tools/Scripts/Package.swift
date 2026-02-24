// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Scripts",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "scripts", targets: ["Scripts"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        .package(path: "../../Agents/metrics")
    ],
    targets: [
        .executableTarget(
            name: "Scripts",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "MetricsCollector", package: "metrics")
            ],
            path: "Sources/Scripts"
        )
    ]
)
