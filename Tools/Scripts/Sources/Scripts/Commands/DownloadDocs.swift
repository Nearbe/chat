// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import ArgumentParser
import Foundation

/// Команда для скачивания документации.
struct DownloadDocs: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Обновление локальной документации инструментов"
    )

    func run() async throws {
        print("🌍  Начало обновления документации...")

        try await Metrics.measure(step: "Download All Docs") {
            try await DocDownloadService.downloadAll()
        }

        print("✅  Вся документация успешно обновлена!")
    }
}
