// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import ArgumentParser
import Foundation

/// Команда для обновления меток связи с документацией.
struct UpdateDocsLinks: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Обновление меток документации в файлах проекта"
    )

    func run() async throws {
        try await Metrics.measure(step: "Update Docs Links") {
            print("🔗  Обновление меток связи с документацией...")
            try await DocumentationService.updateDocLinks()
        }
    }
}
