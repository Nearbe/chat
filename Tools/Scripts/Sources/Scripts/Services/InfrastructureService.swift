// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.

import Foundation

/// Сервис для управления инфраструктурой проекта (XcodeGen, SwiftGen).
enum InfrastructureService {
    /// Запускает XcodeGen.
    static func runXcodeGen() async throws {
        try await Shell.run("xcodegen generate", quiet: true, logName: "XcodeGen")
    }

    /// Запускает SwiftGen.
    static func runSwiftGen() async throws {
        try await SwiftGenService.run()
    }

    /// Запускает полную подготовку инфраструктуры.
    static func runFull() async -> [CheckStepResult] {
        print("🟡  Подготовка инфраструктуры...")

        let xcodegen = await StepExecutor.execute(name: "XcodeGen", emoji: "🛠️") {
            try await runXcodeGen()
        }

        let swiftgen = await StepExecutor.execute(name: "SwiftGen", emoji: "⚙️") {
            try await runSwiftGen()
        }

        return [xcodegen, swiftgen]
    }
}
