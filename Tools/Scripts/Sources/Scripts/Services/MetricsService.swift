// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.

import Foundation
import MetricsCollector

/// Alias для обратной совместимости.
typealias Metrics = MetricsService

/// Сервис для сбора и записи метрик производительности.
/// Использует MetricsCollector с SQLite для хранения данных.
enum MetricsService {
    /// Менеджер базы данных для прямого сохранения записей
    private static let database = DatabaseManager.shared
    
    nonisolated(unsafe) private static var startTime = CFAbsoluteTimeGetCurrent()

    /// Сбрасывает таймер.
    static func start() {
        startTime = CFAbsoluteTimeGetCurrent()
    }

    /// Записывает метрику шага в SQLite.
    /// - Parameters:
    ///   - step: Название шага/операции
    ///   - duration: Продолжительность выполнения в секундах
    ///   - status: Статус выполнения ("Success" или "Failure")
    static func record(step: String, duration: TimeInterval, status: String) {
        // Определяем код завершения на основе статуса
        let exitCode: Int
        let errorsCount: Int

        if status == "Success" {
            exitCode = 0
            errorsCount = 0
        } else {
            exitCode = 1
            errorsCount = 1
        }

        // Создаём запись метрик с точной продолжительностью
        let record = MetricsRecord(
            operation: step,
            timestamp: Date(),
            durationSeconds: duration,
            cpuBefore: 0,
            cpuDuringAvg: 0,
            cpuPeak: 0,
            ramBeforeMB: 0,
            ramDuringAvgMB: 0,
            ramPeakMB: 0,
            exitCode: exitCode,
            warningsCount: 0,
            errorsCount: errorsCount,
            outputSizeKB: 0,
            xcodeVersion: "",
            swiftVersion: "",
            schemeName: ""
        )

        // Сохраняем напрямую в SQLite
        database.save(record)

        print("[Metrics] Записано: \(step) - \(String(format: "%.3f", duration)) сек. [\(status)]")
    }

    /// Измеряет время выполнения асинхронного блока и записывает метрику в SQLite.
    @discardableResult
    static func measure<T>(step: String, block: () async throws -> T) async throws -> T {
        let start = CFAbsoluteTimeGetCurrent()

        do {
            let result = try await block()
            let duration = CFAbsoluteTimeGetCurrent() - start
            record(step: step, duration: duration, status: "Success")
            return result
        } catch {
            let duration = CFAbsoluteTimeGetCurrent() - start
            record(step: step, duration: duration, status: "Failure")
            throw error
        }
    }

    /// Синхронная версия measure для обратной совместимости.
    @discardableResult
    static func measure<T>(step: String, block: () throws -> T) rethrows -> T {
        let start = CFAbsoluteTimeGetCurrent()

        do {
            let result = try block()
            let duration = CFAbsoluteTimeGetCurrent() - start
            record(step: step, duration: duration, status: "Success")
            return result
        } catch {
            let duration = CFAbsoluteTimeGetCurrent() - start
            record(step: step, duration: duration, status: "Failure")
            throw error
        }
    }

    /// Выводит общее время выполнения скрипта.
    static func logTotalTime() {
        let duration = CFAbsoluteTimeGetCurrent() - startTime
        print("\n⏱️  Общее время выполнения скрипта: \(String(format: "%.2f", duration)) сек.")
    }

    /// Получить все записи метрик из базы данных.
    static func fetchAll() -> [MetricsRecord] {
        return database.fetchAll()
    }

    /// Получить записи по названию операции.
    static func fetch(byOperation operation: String, limit: Int = 10) -> [MetricsRecord] {
        return database.fetch(byOperation: operation, limit: limit)
    }

    /// Получить статистику по операции.
    static func stats(forOperation operation: String) -> MetricsStats? {
        return database.stats(forOperation: operation)
    }
}
