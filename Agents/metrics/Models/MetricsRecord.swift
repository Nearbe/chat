// MARK: - Связь с документацией: SQLite.swift (Версия 0.15.3). Статус: Синхронизировано.
import Foundation

/// Запись метрик выполнения операции.
/// Хранится в SQLite базе данных для анализа производительности.
///
/// Связь с документацией:
/// - SQLite.swift: https://github.com/stephencelis/SQLite.swift
struct MetricsRecord: Codable, Sendable {
    // MARK: - Идентификация

    /// Уникальный идентификатор записи
    let id: UUID

    /// Название операции (xcodebuild, test, check, ship)
    let operation: String

    /// Timestamp начала операции
    let timestamp: Date

    // MARK: - Временные метрики

    /// Продолжительность операции в секундах
    var durationSeconds: Double

    // MARK: - CPU метрики (в процентах)

    /// CPU до начала операции (0-100)
    var cpuBefore: Double

    /// Среднее CPU во время операции
    var cpuDuringAvg: Double

    /// Пиковое значение CPU
    var cpuPeak: Double

    // MARK: - RAM метрики (в MB)

    /// RAM до начала операции
    var ramBeforeMB: Int

    /// Средняя RAM во время операции
    var ramDuringAvgMB: Int

    /// Пиковое значение RAM
    var ramPeakMB: Int

    // MARK: - Результат выполнения

    /// Код завершения (0 = успех)
    var exitCode: Int

    /// Количество warnings
    var warningsCount: Int

    /// Количество errors
    var errorsCount: Int

    // MARK: - Артефакты

    /// Размер вывода в KB
    var outputSizeKB: Int

    // MARK: - Метаданные

    /// Версия Xcode
    var xcodeVersion: String

    /// Версия Swift
    var swiftVersion: String

    /// Имя схемы (Chat, Check, Ship)
    var schemeName: String

    // MARK: - Инициализация

    init(
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
}

// MARK: - Удобные методы

extension MetricsRecord {
    /// Успешная ли операция
    var isSuccess: Bool {
        exitCode == 0
    }

    /// Форматированная продолжительность
    var formattedDuration: String {
        if durationSeconds < 60 {
            return String(format: "%.1fs", durationSeconds)
        } else {
            let minutes = Int(durationSeconds) / 60
            let seconds = Int(durationSeconds) % 60
            return "\(minutes)m \(seconds)s"
        }
    }

    /// Сводка по ресурсам
    var resourcesSummary: String {
        """
        CPU: \(String(format: "%.0f", cpuDuringAvg))% avg, \(String(format: "%.0f", cpuPeak))% peak
        RAM: \(ramDuringAvgMB) MB avg, \(ramPeakMB) MB peak
        """
    }
}
