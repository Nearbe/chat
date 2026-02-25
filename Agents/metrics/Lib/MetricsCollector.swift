// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.

import Foundation

/// Основной сервис сбора метрик.
/// Объединяет мониторинг ресурсов и сохранение в базу данных.
public final class MetricsCollector: @unchecked Sendable {

    // MARK: - Singleton

    public static let shared = MetricsCollector()

    // MARK: - Зависимости

    private let database = DatabaseManager.shared

    // MARK: - Состояние

    private var currentOperation: String?
    private var startTime: Date?
    private var startSnapshot: ResourceMonitor.Snapshot?
    private let resourceMonitor = ResourceMonitor()

    // MARK: - Системная информация

    private var xcodeVersion: String {
        getXcodeVersion()
    }

    private var swiftVersion: String {
        getSwiftVersion()
    }

    private var macOSVersion: String {
        getMacOSVersion()
    }

    // MARK: - Публичные методы

    /// Начать сбор метрик для операции
    public func start(operation: String,
    scheme: String? = nil) {
        guard currentOperation == nil else {
            print("[Metrics] Warning: Operation \(currentOperation ?? "") already in progress")
            return
        }

        currentOperation = operation
        startTime = Date()
        startSnapshot = resourceMonitor.currentSnapshot()

        // Запускаем мониторинг ресурсов
        resourceMonitor.start()

        print("[Metrics] Started: \(operation)")
    }

    /// Остановить сбор метрик
    public func stop(exitCode: Int,
    warningsCount: Int = 0,
    errorsCount: Int = 0,
    outputSizeKB: Int = 0,
    scheme: String? = nil,
    // Параметры метрик проекта
    sloc: Int = 0,
    fileCount: Int = 0,
    testCount: Int = 0,
    codeCoveragePercent: Double = 0,
    bundleSizeKB: Int = 0,
    dependenciesCount: Int = 0) {
        guard let operation = currentOperation,
        let start = startTime else {
            print("[Metrics] Warning: No operation in progress")
            return
        }

        // Останавливаем мониторинг
        let resourceStats = resourceMonitor.stop()

        let duration = Date().timeIntervalSince(start)

        // Создаём запись
        let record = MetricsRecord(
            operation: operation,
            timestamp: start,
            durationSeconds: duration,
            cpuBefore: startSnapshot?.cpuPercent ?? 0,
            cpuDuringAvg: resourceStats.cpuAvg,
            cpuPeak: resourceStats.cpuPeak,
            ramBeforeMB: startSnapshot?.usedMemoryMB ?? 0,
            ramDuringAvgMB: resourceStats.ramAvgMB,
            ramPeakMB: resourceStats.ramPeakMB,
            exitCode: exitCode,
            warningsCount: warningsCount,
            errorsCount: errorsCount,
            outputSizeKB: outputSizeKB,
            xcodeVersion: xcodeVersion,
            swiftVersion: swiftVersion,
            macOSVersion: macOSVersion,
            schemeName: scheme ?? "",
            sloc: sloc,
            fileCount: fileCount,
            testCount: testCount,
            codeCoveragePercent: codeCoveragePercent,
            bundleSizeKB: bundleSizeKB,
            dependenciesCount: dependenciesCount
        )

        // Сохраняем в базу
        database.save(record)

        // Сброс состояния
        currentOperation = nil
        startTime = nil
        startSnapshot = nil

        print("[Metrics] Completed: \(operation) - \(record.formattedDuration)")
    }

    /// Отменить текущую операцию
    public func cancel() {
        _ = resourceMonitor.stop()
        currentOperation = nil
        startTime = nil
        startSnapshot = nil
        print("[Metrics] Cancelled")
    }

    /// Получить все записи
    public func fetchAll() -> [MetricsRecord] {
        database.fetchAll()
    }

    /// Получить записи по операции
    public func fetch(byOperation operation: String, limit: Int = 10) -> [MetricsRecord] {
        database.fetch(byOperation: operation, limit: limit)
    }

    /// Получить статистику
    public func stats(forOperation operation: String) -> MetricsStats? {
        database.stats(forOperation: operation)
    }

    /// Очистить старые записи
    public func cleanup(olderThanDays: Int = 30) {
        database.cleanup(olderThanDays: olderThanDays)
    }

    // MARK: - Вспомогательные

    private func getXcodeVersion() -> String {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/xcodebuild")
        task.arguments = ["-version"]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = FileHandle.nullDevice

        do {
            try task.run()
            task.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                let lines = output.components(separatedBy: "\n")
                if let versionLine = lines.first(where: {
                    $0.hasPrefix("Xcode")
                }) {
                    return versionLine.trimmingCharacters(in: .whitespaces)
                }
            }
        } catch {
            return "Unknown"
        }

        return "Unknown"
    }

    private func getSwiftVersion() -> String {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
        task.arguments = ["--version"]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = FileHandle.nullDevice

        do {
            try task.run()
            task.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                let line = output.components(separatedBy: "\n").first ?? ""
                return line.trimmingCharacters(in: .whitespaces)
            }
        } catch {
            return "Unknown"
        }

        return "Unknown"
    }

    /// Получить версию macOS
    private func getMacOSVersion() -> String {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/sw_vers")
        task.arguments = ["-productVersion"]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = FileHandle.nullDevice

        do {
            try task.run()
            task.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                let version = output.trimmingCharacters(in: .whitespacesAndNewlines)
                // Добавляем имя версии для информативности
                let versionName = getMacOSVersionName(version)
                return "\(version) (\(versionName))"
            }
        } catch {
            return "Unknown"
        }

        return "Unknown"
    }

    /// Получить кодовое имя версии macOS
    private func getMacOSVersionName(_ version: String) -> String {
        let majorVersion = version.split(separator: ".").first.flatMap {
            Int($0)
        } ?? 0

        switch majorVersion {
        case 14:
            return "Sonoma"
        case 13:
            return "Ventura"
        case 12:
            return "Monterey"
        case 11:
            return "Big Sur"
        case 10:
            return "Catalina"
        default:
            return "Unknown"
        }
    }
}

// MARK: - Удобные методы для скриптов

extension MetricsCollector {

    /// Обёртка для выполнения команды с метриками
    public func measure<T>(operation: String,
    scheme: String? = nil,
    run: () throws -> T) rethrows -> T {
        start(operation: operation, scheme: scheme)

        do {
            let result = try run()
            stop(exitCode: 0)
            return result
        } catch {
            stop(exitCode: 1)
            throw error
        }
    }
}
