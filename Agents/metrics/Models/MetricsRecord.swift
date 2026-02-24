// MARK: - Связь с документацией: SQLite.swift (Версия 0.15.3). Статус: Синхронизировано.
import Foundation

/// Запись метрик выполнения операции.
/// Хранится в SQLite базе данных для анализа производительности.
public struct MetricsRecord: Codable {
    public let id: UUID
    public let operation: String
    public let timestamp: Date
    public var durationSeconds: Double
    public var cpuBefore: Double
    public var cpuDuringAvg: Double
    public var cpuPeak: Double
    public var ramBeforeMB: Int
    public var ramDuringAvgMB: Int
    public var ramPeakMB: Int
    public var exitCode: Int
    public var warningsCount: Int
    public var errorsCount: Int
    public var outputSizeKB: Int
    public var xcodeVersion: String
    public var swiftVersion: String
    public var schemeName: String

    public init(
        id: UUID = UUID(),
        operation: String,
        timestamp: Date = Date(),
        durationSeconds: Double = 0,
        cpuBefore: Double = 0,
        cpuDuringAvg: Double = 0,
        cpuPeak: Double = 0,
        ramBeforeMB: Int = 0,
        ramDuringAvgMB: Int = 0,
        ramPeakMB: Int = 0,
        exitCode: Int = -1,
        warningsCount: Int = 0,
        errorsCount: Int = 0,
        outputSizeKB: Int = 0,
        xcodeVersion: String = "",
        swiftVersion: String = "",
        schemeName: String = ""
    ) {
        self.id = id
        self.operation = operation
        self.timestamp = timestamp
        self.durationSeconds = durationSeconds
        self.cpuBefore = cpuBefore
        self.cpuDuringAvg = cpuDuringAvg
        self.cpuPeak = cpuPeak
        self.ramBeforeMB = ramBeforeMB
        self.ramDuringAvgMB = ramDuringAvgMB
        self.ramPeakMB = ramPeakMB
        self.exitCode = exitCode
        self.warningsCount = warningsCount
        self.errorsCount = errorsCount
        self.outputSizeKB = outputSizeKB
        self.xcodeVersion = xcodeVersion
        self.swiftVersion = swiftVersion
        self.schemeName = schemeName
    }

    public var isSuccess: Bool {
        exitCode == 0
    }

    public var formattedDuration: String {
        if durationSeconds < 60 {
            return String(format: "%.1fs", durationSeconds)
        } else {
            let minutes = Int(durationSeconds) / 60
            let seconds = Int(durationSeconds) % 60
            return "\(minutes)m \(seconds)s"
        }
    }

    public var resourcesSummary: String {
        """
        CPU: \(String(format: "%.0f", cpuDuringAvg))% avg, \(String(format: "%.0f", cpuPeak))% peak
        RAM: \(ramDuringAvgMB) MB avg, \(ramPeakMB) MB peak
        """
    }
}
