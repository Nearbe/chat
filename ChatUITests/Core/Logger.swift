// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.

import Foundation

/// Логгер для тестов
public struct Logger {

    /// Тип лога
    public enum LogType: String {
        /// Отладочный лог
        case debug
        /// Информационный лог
        case info
        /// Предупреждение
        case warning
        /// Ошибка
        case error

        /// Иконка для типа лога
        var mark: String {
            switch self {
            case .debug:
                return "🟢"
            case .info:
                return "🔵"
            case .warning:
                return "🟠"
            case .error:
                return "🔴"
            }
        }
    }

    private static var fileHandle: FileHandle?
    /// Путь к файлу логов
    public private(set) static var logFilePath: String?
    /// Включено ли логирование в файл
    public static var shouldEnableLogs: Bool = true

    private init() {
    }

    /// Инициализация файлового логирования
    public static func initializeFileLogger() {
        guard shouldEnableLogs else {
            return
        }

        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first !
        let logsDirectory = documentsPath.appendingPathComponent("Logs", isDirectory: true)

        // Создать директорию если не существует
        try ? FileManager.default.createDirectory(at: logsDirectory, withIntermediateDirectories: true)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let fileName = "test_log_\(dateFormatter.string(from: Date())).txt"
        let fileURL = logsDirectory.appendingPathComponent(fileName)

        logFilePath = fileURL.path

        // Создать файл
        FileManager.default.createFile(atPath: fileURL.path, contents: nil)
        fileHandle = try ? FileHandle(forWritingTo: fileURL)
    }

    /// Получить URL файла логов
    public static var logFileURL: URL? {
        guard let path = logFilePath else {
            return nil
        }
        return URL(fileURLWithPath: path)
    }

    /// Записать в файл
    private static func writeToFile(_ message: String) {
        guard let fileHandle = fileHandle, shouldEnableLogs else {
            return
        }
        let data = (message + "\n").data(using: .utf8) !
        fileHandle.write(data)
    }

    /// Закрыть файл
    public static func closeFileLogger() {
        try ? fileHandle?.close()
        fileHandle = nil
    }
}

public extension Logger {

    /// Логирование отладочного сообщения
    static func debug(_ subject: Any,
    file: String = #fileID,
    line: UInt = #line,
    function: String = #function) {
        performLog(subject, type: .debug, file: file, line: line, function: function)
    }

    /// Логирование информационного сообщения
    static func info(_ subject: Any,
    file: String = #fileID,
    line: UInt = #line,
    function: String = #function) {
        performLog(subject, type: .info, file: file, line: line, function: function)
    }

    /// Логирование предупреждения
    static func warning(_ subject: Any,
    file: String = #fileID,
    line: UInt = #line,
    function: String = #function) {
        performLog(subject, type: .warning, file: file, line: line, function: function)
    }

    /// Логирование ошибки
    static func error(_ subject: Any,
    file: String = #fileID,
    line: UInt = #line,
    function: String = #function) {
        performLog(subject, type: .error, file: file, line: line, function: function)
    }
}

private extension Logger {

    static func fileName(from file: String) -> String {
        URL(fileURLWithPath: file).deletingPathExtension().lastPathComponent
    }

    static func performLog(_ subject: Any,
    type: LogType,
    file: String,
    line: UInt,
    function: String) {
        let fileName = self.fileName(from: file)
        let logString = "\(type.mark) \(type.rawValue.uppercased()) \(fileName).\(function):\(line) - \(subject)"
        NSLog(logString)
        writeToFile(logString)
    }
}

private func getEnvironmentVariable(_ name: String, swallowAssert: Bool = false) -> String {
    guard let value = ProcessInfo.processInfo.environment[name] else {
        return ""
    }
    return value
}
