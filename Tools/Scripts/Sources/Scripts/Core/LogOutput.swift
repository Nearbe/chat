// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import Foundation

/// Перехватывает stdout и записывает вывод в файл, дублируя в консоль.
/// Позволяет сохранять вывод скриптов для просмотра в IDE.
public final class LogOutput: @unchecked Sendable {
    /// Путь к директории логов
    private let logDirectory: URL

    /// Имя лог-файла
    private let logFileName: String

    /// Путь к текущему лог-файлу
    private var logFilePath: URL?

    /// Файловый дескриптор для записи
    private var fileHandle: FileHandle?

    /// Блокировка для потокобезопасной записи
    private let lock = NSLock()

    /// Конструктор
    /// - Parameters:
    ///   - logDirectory: Директория для логов (по умолчанию Logs/Check)
    ///   - logFileName: Имя лог-файла (по умолчанию CheckRun)
    public init(logDirectory: String = "Logs/Check", logFileName: String = "CheckRun") {
        self.logDirectory = URL(fileURLWithPath: logDirectory)
        self.logFileName = logFileName
    }

    /// Начинает логирование
    public func start() throws {
        // Создаем директорию если нет
        try FileManager.default.createDirectory(at: logDirectory, withIntermediateDirectories: true)

        // Формируем путь к файлу с таймстемпом
        let timestamp = Self.dateFormatter.string(from: Date())
        let fileName = "\(logFileName)_\(timestamp).log"
        let fileURL = logDirectory.appendingPathComponent(fileName)

        // Создаем файл
        FileManager.default.createFile(atPath: fileURL.path, contents: nil)

        // Открываем файл для записи
        fileHandle = try FileHandle(forWritingTo: fileURL)
        logFilePath = fileURL

        // Заголовок лога
        let header = """
        ================================================================================
        ===  LOG OUTPUT: \(logFileName)
        ===  DATE: \(Date())
        ===  ================================================================================

        """
        write(header, toConsole: false)
    }

    /// Останавливает логирование и закрывает файл
    public func stop() {
        // Записываем завершающую часть
        let footer = "\n\n================================================================================\n===  END OF LOG\n================================================================================\n"
        write(footer, toConsole: false)

        // Закрываем файл
        try? fileHandle?.close()
        fileHandle = nil
    }

    /// Записывает строку в лог-файл
    /// - Parameters:
    ///   - text: Текст для записи
    ///   - toConsole: Также выводить в консоль
    public func write(_ text: String, toConsole: Bool = true) {
        guard let data = text.data(using: .utf8) else { return }

        lock.lock()
        defer { lock.unlock() }

        // Записываем в файл
        try? fileHandle?.write(contentsOf: data)

        // Также в консоль
        if toConsole {
            print(text, terminator: "")
        }
    }

    /// Записывает строку с переносом строки
    public func writeln(_ text: String = "", toConsole: Bool = true) {
        write(text + "\n", toConsole: toConsole)
    }

    /// Возвращает путь к лог-файлу
    public var currentLogFilePath: String? {
        logFilePath?.path
    }

    // MARK: - Private

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return formatter
    }()
}

/// Глобальный логгер для использования в скриптах
public final class GlobalLogger: @unchecked Sendable {
    public static let shared = GlobalLogger()

    private var logger: LogOutput?
    private let lock = NSLock()

    private init() {}

    /// Текущий активный логгер
    public var current: LogOutput? {
        lock.lock()
        defer { lock.unlock() }
        return logger
    }

    /// Начинает логирование
    public func start(logFileName: String = "CheckRun") throws -> LogOutput {
        lock.lock()
        defer { lock.unlock() }

        let newLogger = LogOutput(logFileName: logFileName)
        try newLogger.start()
        logger = newLogger
        return newLogger
    }

    /// Останавливает логирование
    public func stop() {
        lock.lock()
        defer { lock.unlock() }

        logger?.stop()
        logger = nil
    }

    /// Записывает строку
    public func write(_ text: String) {
        logger?.write(text)
    }

    /// Записывает строку с переносом
    public func writeln(_ text: String = "") {
        logger?.writeln(text)
    }

    /// Возвращает путь к логу
    public var logPath: String? {
        lock.lock()
        defer { lock.unlock() }
        return logger?.currentLogFilePath
    }
}

/// Утилита для быстрого доступа к логированию вывода
public enum Log {
    /// Начинает логирование
    public static func start(logFileName: String = "CheckRun") throws -> LogOutput {
        try GlobalLogger.shared.start(logFileName: logFileName)
    }

    /// Останавливает логирование
    public static func stop() {
        GlobalLogger.shared.stop()
    }

    /// Записывает строку
    public static func write(_ text: String) {
        GlobalLogger.shared.write(text)
    }

    /// Записывает строку с переносом
    public static func writeln(_ text: String = "") {
        GlobalLogger.shared.writeln(text)
    }

    /// Возвращает путь к последнему логу
    public static var lastLogPath: String? {
        GlobalLogger.shared.logPath
    }
}
