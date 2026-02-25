// MARK: - Связь с документацией: SQLite.swift (Версия 0.15.3). Статус: Синхронизировано.
import Foundation
@preconcurrency import SQLite

/// Менеджер базы данных SQLite для хранения метрик.
/// Обеспечивает сохранение и запрос метрик выполнения операций.
final class DatabaseManager: @unchecked Sendable {

    // MARK: - Singleton

    static let shared = DatabaseManager()

    // MARK: - Подключение

    private var db: Connection?

    // MARK: - Таблица

    private let metrics = Table("metrics")

    // MARK: - Колонки

    private let colId = Expression<String>("id")
    private let colOperation = Expression<String>("operation")
    private let colTimestamp = Expression<Date>("timestamp")
    private let colDurationSeconds = Expression<Double>("duration_seconds")
    private let colCpuBefore = Expression<Double>("cpu_before")
    private let colCpuDuringAvg = Expression<Double>("cpu_during_avg")
    private let colCpuPeak = Expression<Double>("cpu_peak")
    private let colRamBeforeMB = Expression<Int>("ram_before_mb")
    private let colRamDuringAvgMB = Expression<Int>("ram_during_avg_mb")
    private let colRamPeakMB = Expression<Int>("ram_peak_mb")
    private let colExitCode = Expression<Int>("exit_code")
    private let colWarningsCount = Expression<Int>("warnings_count")
    private let colErrorsCount = Expression<Int>("errors_count")
    private let colOutputSizeKB = Expression<Int>("output_size_kb")
    private let colXcodeVersion = Expression<String>("xcode_version")
    private let colSwiftVersion = Expression<String>("swift_version")
    private let colSchemeName = Expression<String>("scheme_name")

    // MARK: - Путь к базе

    private var databasePath: String {
        let workspacePath = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("repositories/Chat/Agents/metrics/workspace")
        return workspacePath.appendingPathComponent("metrics.db").path
    }

    // MARK: - Инициализация

    private init() {
        // Вычисляем путь к базе
        let workspacePath = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("repositories/Chat/Agents/metrics/workspace")
        let dbPath = workspacePath.appendingPathComponent("metrics.db").path

        do {
            // Создаём директорию если нет
            let directory = (dbPath as NSString).deletingLastPathComponent
            try FileManager.default.createDirectory(
                atPath: directory,
                withIntermediateDirectories: true
            )

            // Подключаемся к базе
            db = try Connection(dbPath)

            // Создаём таблицу
            try createTable()

            print("[Metrics] Database initialized at: \(dbPath)")
        } catch {
            print("[Metrics] Database init failed: \(error)")
            db = nil
        }
    }

    // MARK: - Создание таблицы

    private func createTable() throws {
        guard let db = db else { return }

        try db.run(metrics.create(ifNotExists: true) { t in
            t.column(colId, primaryKey: true)
            t.column(colOperation)
            t.column(colTimestamp)
            t.column(colDurationSeconds)
            t.column(colCpuBefore)
            t.column(colCpuDuringAvg)
            t.column(colCpuPeak)
            t.column(colRamBeforeMB)
            t.column(colRamDuringAvgMB)
            t.column(colRamPeakMB)
            t.column(colExitCode)
            t.column(colWarningsCount)
            t.column(colErrorsCount)
            t.column(colOutputSizeKB)
            t.column(colXcodeVersion)
            t.column(colSwiftVersion)
            t.column(colSchemeName)
        })

        // Создаём индексы для часто используемых запросов
        try ? db.run(metrics.createIndex(colOperation, ifNotExists: true))
        try ? db.run(metrics.createIndex(colTimestamp, ifNotExists: true))
    }

    // MARK: - CRUD операции

    /// Сохранить запись метрик
    func save(_ record: MetricsRecord) {
        guard let db = db else { return }

        do {
            let insert = metrics.insert(
                colId <- record.id.uuidString,
                colOperation <- record.operation,
                colTimestamp <- record.timestamp,
                colDurationSeconds <- record.durationSeconds,
                colCpuBefore <- record.cpuBefore,
                colCpuDuringAvg <- record.cpuDuringAvg,
                colCpuPeak <- record.cpuPeak,
                colRamBeforeMB <- record.ramBeforeMB,
                colRamDuringAvgMB <- record.ramDuringAvgMB,
                colRamPeakMB <- record.ramPeakMB,
                colExitCode <- record.exitCode,
                colWarningsCount <- record.warningsCount,
                colErrorsCount <- record.errorsCount,
                colOutputSizeKB <- record.outputSizeKB,
                colXcodeVersion <- record.xcodeVersion,
                colSwiftVersion <- record.swiftVersion,
                colSchemeName <- record.schemeName
            )
            try db.run(insert)
            print("[Metrics] Saved: \(record.operation) (\(record.formattedDuration))")
        } catch {
            print("[Metrics] Save failed: \(error)")
        }
    }

    /// Получить все записи
    func fetchAll() -> [MetricsRecord] {
        guard let db = db else { return [] }

        do {
            return try db.prepare(metrics.order(colTimestamp.desc)).map { row in
                mapRowToRecord(row)
            }
        } catch {
            print("[Metrics] Fetch failed: \(error)")
            return []
        }
    }

    /// Получить записи по операции
    func fetch(byOperation operation: String, limit: Int = 10) -> [MetricsRecord] {
        guard let db = db else { return [] }

        do {
            let query = metrics
                .filter(colOperation == operation)
                .order(colTimestamp.desc)
                .limit(limit)

            return try db.prepare(query).map { row in
                mapRowToRecord(row)
            }
        } catch {
            print("[Metrics] Fetch by operation failed: \(error)")
            return []
        }
    }

    /// Получить последнюю запись
    func fetchLast() -> MetricsRecord? {
        guard let db = db else { return nil }

        do {
            let query = metrics.order(colTimestamp.desc).limit(1)
            return try db.prepare(query).compactMap { mapRowToRecord($0) }.first
        } catch {
            return nil
        }
    }

    /// Получить статистику по операции
    func stats(forOperation operation: String) -> MetricsStats? {
        guard let db = db else { return nil }

        do {
            let query = metrics.filter(colOperation == operation)

            let avgDuration = try db.scalar(query.select(colDurationSeconds.average)) ?? 0
            let avgCPU = try db.scalar(query.select(colCpuDuringAvg.average)) ?? 0
            let avgRAM = try db.scalar(query.select(colRamDuringAvgMB.average)) ?? 0
            let count = try db.scalar(query.count)

            return MetricsStats(
                operation: operation,
                avgDuration: avgDuration,
                avgCPU: avgCPU,
                avgRAM: Int(avgRAM),
                executionCount: count
            )
        } catch {
            return nil
        }
    }

    /// Удалить старые записи (старше 30 дней)
    func cleanup(olderThanDays: Int = 30) {
        guard let db = db else { return }

        let cutoffDate = Calendar.current.date(byAdding: .day, value: -olderThanDays, to: Date())!

        do {
            let oldRecords = metrics.filter(colTimestamp < cutoffDate)
            let deleted = try db.run(oldRecords.delete())
            print("[Metrics] Cleaned up \(deleted) old records")
        } catch {
            print("[Metrics] Cleanup failed: \(error)")
        }
    }

    // MARK: - Вспомогательные

    private func mapRowToRecord(_ row: Row) -> MetricsRecord {
        MetricsRecord(
            id: UUID(uuidString: row[colId]) ?? UUID(),
            operation: row[colOperation],
            timestamp: row[colTimestamp],
            durationSeconds: row[colDurationSeconds],
            cpuBefore: row[colCpuBefore],
            cpuDuringAvg: row[colCpuDuringAvg],
            cpuPeak: row[colCpuPeak],
            ramBeforeMB: row[colRamBeforeMB],
            ramDuringAvgMB: row[colRamDuringAvgMB],
            ramPeakMB: row[colRamPeakMB],
            exitCode: row[colExitCode],
            warningsCount: row[colWarningsCount],
            errorsCount: row[colErrorsCount],
            outputSizeKB: row[colOutputSizeKB],
            xcodeVersion: row[colXcodeVersion],
            swiftVersion: row[colSwiftVersion],
            schemeName: row[colSchemeName]
        )
    }
}

// MARK: - Статистика

public struct MetricsStats {
    public let operation: String
    public let avgDuration: Double
    public let avgCPU: Double
    public let avgRAM: Int
    public let executionCount: Int

    public init(operation: String, avgDuration: Double, avgCPU: Double, avgRAM: Int, executionCount: Int) {
        self.operation = operation
        self.avgDuration = avgDuration
        self.avgCPU = avgCPU
        self.avgRAM = avgRAM
        self.executionCount = executionCount
    }
}
