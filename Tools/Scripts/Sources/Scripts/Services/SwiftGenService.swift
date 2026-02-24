// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.

import Foundation

/// Сервис для запуска SwiftGen.
enum SwiftGenService {
    /// Запускает SwiftGen.
    static func run() async throws {
        try await Shell.run("swiftgen", quiet: true, logName: "SwiftGen")
        try fixColorAsset()
    }

    /// Исправляет проблему с ColorAsset для concurrency.
    private static func fixColorAsset() throws {
        let assetsFile = URL(fileURLWithPath: "Design/Generated/Assets.swift")
        guard FileManager.default.fileExists(atPath: assetsFile.path) else {
            return
        }

        var content = try String(contentsOf: assetsFile, encoding: .utf8)
        content = content.replacingOccurrences(
            of: "internal final class ColorAsset",
            with: "internal final class ColorAsset: @unchecked Sendable"
        )
        try content.write(to: assetsFile, atomically: true, encoding: .utf8)
    }
}
