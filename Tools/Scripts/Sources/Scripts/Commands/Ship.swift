// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import ArgumentParser
import Foundation
import MetricsCollector

/// Команда для выполнения финальной проверки и подготовки проекта к отправке.
struct Ship: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Доставка продукта (Release Build + Deploy)"
    )

    func run() async throws {
        // Start metrics collection
        MetricsCollector.shared.start(operation: "ship", scheme: "Ship")

        print("🚢  Начало доставки продукта...")

        let deviceName = "Saint Celestine"

        do {
            try await BuildService.ship(deviceName: deviceName)
            print("📦  Продукт успешно доставлен на устройство '\(deviceName)'!")

            // Сбор метрик проекта после успешного билда
            let projectMetrics = ProjectMetricsCollector.collect()

            // Останавливаем сбор метрик с параметрами проекта
            MetricsCollector.shared.stop(
                exitCode: 0,
                sloc: projectMetrics.sloc,
                fileCount: projectMetrics.fileCount,
                testCount: projectMetrics.testCount,
                codeCoveragePercent: projectMetrics.codeCoveragePercent,
                bundleSizeKB: projectMetrics.bundleSizeKB,
                dependenciesCount: projectMetrics.dependenciesCount
            )
        } catch {
            MetricsCollector.shared.stop(exitCode: 1)
            throw error
        }
    }
}
