// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import Foundation

public struct Metrics {
    private static let fileName = "metrics.csv"
    private static let lock = NSLock()

    private static var fileURL: URL {
        URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent(fileName)
    }

    public static func record(step: String, duration: TimeInterval, status: String) {
        lock.lock()
        defer { lock.unlock() }

        let date = ISO8601DateFormatter().string(from: Date())
        let escapedStep = step.contains(",") ? "\"\(step)\"" : step
        let line = "\(date),\(escapedStep),\(String(format: "%.3f", duration)),\(status)\n"

        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: fileURL.path) {
            let header = "Date,Step,Duration(s),Status\n"
            try? header.write(to: fileURL, atomically: true, encoding: .utf8)
        }

        if let fileHandle = try? FileHandle(forWritingTo: fileURL),
           let data = line.data(using: .utf8) {
            defer { try? fileHandle.close() }
            try? fileHandle.seekToEndOfFile()
            try? fileHandle.write(contentsOf: data)
        }
    }

    @discardableResult
    public static func measure<T>(step: String, block: () async throws -> T) async throws -> T {
        let start = Date()
        do {
            let result = try await block()
            let duration = Date().timeIntervalSince(start)
            record(step: step, duration: duration, status: "Success")
            return result
        } catch {
            let duration = Date().timeIntervalSince(start)
            record(step: step, duration: duration, status: "Failure")
            throw error
        }
    }
}
