// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import ArgumentParser
import Foundation

/// Команда для начальной настройки окружения и инфраструктуры проекта.
struct Setup: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Подготовка проекта к работе (XcodeGen + SwiftGen)"
    )

    func run() async throws {
        print("🏗️  Подготовка проекта...")

        try await Metrics.measure(step: "Ensure Dependencies") {
            try await DependencyService.ensureDependencies()
        }

        try await Metrics.measure(step: "Setup Assets") {
            try await AssetSetupService.setup()
        }

        try await Metrics.measure(step: "XcodeGen") {
            print("🏗️  Генерация Xcode проекта (XcodeGen)...")
            try await Shell.run("xcodegen generate")
        }

        try await Metrics.measure(step: "SwiftGen") {
            print("🎨 Генерация ресурсов (SwiftGen)...")
            try await SwiftGenService.run()
        }

        print("✅ Проект готов к работе!")
    }
}
