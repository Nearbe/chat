// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import ArgumentParser
import Foundation

/// Команда для настройки беспарольного sudo.
struct ConfigureSudo: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Настройка беспарольного запуска ship через sudo"
    )

    func run() async throws {
        try await Metrics.measure(step: "Configure Sudo") {
            try await SudoConfigService.configure()
        }
    }
}
