// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import Foundation

/// Система сбора и записи метрик производительности шагов проверки.
public enum Metrics {
    private static let fileName = "metrics.csv"
    private static let lock = NSLock()
    nonisolated(unsafe) private static var startTime = CFAbsoluteTimeGetCurrent()

    /// Сбрасывает таймер начала выполнения
    public static func start() {
        startTime = CFAbsoluteTimeGetCurrent()
    }

    private static var fileURL: URL {
        URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent(fileName)
    }

    /// Записывает метрику шага в файл
    /// - Parameters:
    ///   - step: Название шага
    ///   - duration: Длительность в секундах
    ///   - status: Статус выполнения (Success/Failure)
    public static func record(step: String, duration: TimeInterval, status: String) {
        lock.lock()
        defer { lock.unlock() }

        let date = ISO8601DateFormatter().string(from: Date())
        let escapedStep = step.contains(",") ? "\"\(step)\"" : step
        let line = "\(date),\(escapedStep),\(String(format: "%.3f", duration)),\(status)\n"

        // Вывод в консоль удален для чистоты Human Readable вывода. 
        // Если нужно, можно добавить флаг verbose.

        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: fileURL.path) {
            let header = "Date,Step,Duration(s),Status\n"
            _ = try? header.write(to: fileURL, atomically: true, encoding: .utf8)
        }

        if let fileHandle = try? FileHandle(forWritingTo: fileURL),
           let data = line.data(using: .utf8) {
            defer { try? fileHandle.close() }
            fileHandle.seekToEndOfFile()
            fileHandle.write(data)
        }
    }

    /// Измеряет время выполнения блока кода и записывает результат
    /// - Parameters:
    ///   - step: Название шага для логирования
    ///   - block: Асинхронный блок кода для выполнения
    /// - Returns: Результат выполнения блока
    @discardableResult
    public static func measure<T>(step: String, block: () async throws -> T) async throws -> T {
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

    /// Выводит общее время выполнения скрипта в консоль
    public static func logTotalTime() {
        let duration = CFAbsoluteTimeGetCurrent() - startTime
        print("\n🏁  Общее время выполнения скрипта: \(String(format: "%.2f", duration)) сек.")
    }
}
