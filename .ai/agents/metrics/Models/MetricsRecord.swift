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
    public var macOSVersion: String
    public var schemeName: String

    // MARK: - Метрики проекта

    /// Количество строк кода (SLOC) - только Swift файлы
    public var sloc: Int
    /// Количество файлов в проекте
    public var fileCount: Int
    /// Количество тестов
    public var testCount: Int
    /// Процент покрытия тестами (0-100)
    public var codeCoveragePercent: Double
    /// Размер бандла в KB
    public var bundleSizeKB: Int
    /// Количество SPM зависимостей
    public var dependenciesCount: Int

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
    macOSVersion: String = "",
    schemeName: String = "",
    sloc: Int = 0,
    fileCount: Int = 0,
    testCount: Int = 0,
    codeCoveragePercent: Double = 0,
    bundleSizeKB: Int = 0,
    dependenciesCount: Int = 0
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
        self.macOSVersion = macOSVersion
        self.schemeName = schemeName
        self.sloc = sloc
        self.fileCount = fileCount
        self.testCount = testCount
        self.codeCoveragePercent = codeCoveragePercent
        self.bundleSizeKB = bundleSizeKB
        self.dependenciesCount = dependenciesCount
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
