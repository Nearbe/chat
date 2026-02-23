// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import Foundation

/// Ошибки, возникающие при выполнении команд в оболочке.
public enum ShellError: Error, LocalizedError {
    case commandFailed(command: String, exitCode: Int32, output: String, error: String)
    case warningsFound(command: String, output: String)

    public var errorDescription: String? {
        switch self {
        case .commandFailed(let command, let exitCode, _, _):
            return "Команда '\(command)' завершилась с кодом \(exitCode)."
        case .warningsFound(let command, _):
            return "Команда '\(command)' завершена с предупреждениями (warnings)."
        }
    }
}

/// Обертка для выполнения команд в терминале.
public enum Shell {
    /// Выполняет команду в терминале и возвращает вывод
    /// - Parameters:
    ///   - command: Строка команды
    ///   - workingDirectory: Рабочая директория (опционально)
    ///   - environment: Переменные окружения (опционально)
    ///   - quiet: Режим тишины
    ///   - isInteractive: Интерактивный режим (вывод напрямую в консоль)
    ///   - streamingPrefix: Префикс для потокового вывода (если задан, вывод будет печататься в реальном времени)
    ///   - failOnWarnings: Считать ли предупреждения ошибкой
    ///   - allowedWarnings: Список разрешенных паттернов предупреждений
    ///   - logName: Имя лог-файла (опционально)
    /// - Returns: Стандартный вывод (stdout)
    @discardableResult
    public static func run(
        _ command: String,
        workingDirectory: URL? = nil,
        environment: [String: String]? = nil,
        quiet: Bool = false,
        isInteractive: Bool = false,
        streamingPrefix: String? = nil,
        failOnWarnings: Bool = true,
        allowedWarnings: [String] = [],
        logName: String? = nil
    ) async throws -> String {
        if !quiet {
            print("▶️  Запуск: \(command)")
        }

        let process = configureProcess(command, workingDirectory: workingDirectory, environment: environment)
        let outputPipe = Pipe()
        let errorPipe = Pipe()

        if !isInteractive {
            process.standardOutput = outputPipe
            process.standardError = errorPipe
        }

        try process.run()

        if isInteractive {
            return try handleInteractiveProcess(process, command: command)
        }

        return try await handleStandardProcess(
            process,
            command: command,
            outputPipe: outputPipe,
            errorPipe: errorPipe,
            streamingPrefix: streamingPrefix,
            failOnWarnings: failOnWarnings,
            allowedWarnings: allowedWarnings,
            logName: logName
        )
    }

    private static func configureProcess(_ command: String, workingDirectory: URL?, environment: [String: String]?) -> Process {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-c", command]

        if let workingDirectory = workingDirectory {
            process.currentDirectoryURL = workingDirectory
        }

        if let environment = environment {
            process.environment = ProcessInfo.processInfo.environment.merging(environment) { (_, new) in new }
        }
        return process
    }

    private static func handleInteractiveProcess(_ process: Process, command: String) throws -> String {
        process.waitUntilExit()
        if process.terminationStatus != 0 {
            throw ShellError.commandFailed(
                command: command,
                exitCode: process.terminationStatus,
                output: "",
                error: "Команда завершилась с ошибкой в интерактивном режиме"
            )
        }
        return ""
    }

    private static func handleStandardProcess(
        _ process: Process,
        command: String,
        outputPipe: Pipe,
        errorPipe: Pipe,
        streamingPrefix: String? = nil,
        failOnWarnings: Bool,
        allowedWarnings: [String] = [],
        logName: String? = nil
    ) async throws -> String {
        final class SafeData: @unchecked Sendable {
            var data = Data()
            private let lock = NSLock()
            func append(_ newData: Data) {
                lock.lock()
                data.append(newData)
                lock.unlock()
            }
        }

        let fullOutput = SafeData()
        let fullError = SafeData()

        // Настраиваем обработчики для чтения в реальном времени
        outputPipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            guard !data.isEmpty else { return }
            fullOutput.append(data)
            if let prefix = streamingPrefix, let line = String(data: data, encoding: .utf8) {
                print("\(prefix) \(line.trimmingCharacters(in: .newlines))")
            }
        }

        errorPipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            guard !data.isEmpty else { return }
            fullError.append(data)
            if let prefix = streamingPrefix, let line = String(data: data, encoding: .utf8) {
                print("\(prefix) [ERROR] \(line.trimmingCharacters(in: .newlines))")
            }
        }

        process.waitUntilExit()

        // Очищаем обработчики
        outputPipe.fileHandleForReading.readabilityHandler = nil
        errorPipe.fileHandleForReading.readabilityHandler = nil

        let output = String(data: fullOutput.data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let error = String(data: fullError.data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if let logName = logName {
            logCommandOutput(name: logName, command: command, output: output, error: error)
        }

        if failOnWarnings {
            try checkForWarnings(output: output, error: error, command: command, allowedWarnings: allowedWarnings)
        }

        if process.terminationStatus != 0 {
            throw ShellError.commandFailed(
                command: command,
                exitCode: process.terminationStatus,
                output: output,
                error: error
            )
        }

        return output
    }

    private static func checkForWarnings(output: String, error: String, command: String, allowedWarnings: [String]) throws {
        let fullOutput = "\(output)\n\(error)"
        let lowercasedOutput = fullOutput.lowercased()
        let warningKeywords = ["warning:", "ignoring --strip-bitcode"]

        // Сначала проверяем на наличие предупреждений
        var hasWarning = false
        for keyword in warningKeywords where lowercasedOutput.contains(keyword.lowercased()) {
            hasWarning = true
            break
        }

        guard hasWarning else { return }

        // Список ключевых слов, которые мы считаем предупреждениями и которые нужно проверять в реестре
        let warningStartKeywords = ["warning:", "ignoring --strip-bitcode"]

        // Если нашли предупреждение, проверяем, не входит ли оно в список разрешенных
        // Мы разбиваем вывод по строкам, чтобы точнее сопоставлять паттерны
        let lines = fullOutput.components(separatedBy: .newlines)
        for line in lines {
            let lowercasedLine = line.lowercased()
            let isWarningLine = warningStartKeywords.contains { lowercasedLine.contains($0.lowercased()) }

            if isWarningLine {
                let isAllowed = allowedWarnings.contains { pattern in
                    line.contains(pattern) || lowercasedLine.contains(pattern.lowercased())
                }

                if !isAllowed {
                    // Нашли предупреждение, которого нет в списке исключений
                    throw ShellError.warningsFound(command: command, output: fullOutput)
                }
            }
        }
    }

    /// Записывает содержимое в файл лога
    /// - Parameters:
    ///   - name: Имя лога (будет использовано в названии файла)
    ///   - content: Текстовое содержимое
    public static func logToFile(name: String, content: String) {
        let logDir = URL(fileURLWithPath: "Logs/Check")
        try? FileManager.default.createDirectory(at: logDir, withIntermediateDirectories: true)
        let fileURL = logDir.appendingPathComponent("\(name.replacingOccurrences(of: " ", with: "_")).log")
        try? content.write(to: fileURL, atomically: true, encoding: .utf8)
    }

    private static func logCommandOutput(name: String, command: String, output: String, error: String) {
        let logContent = """
        DATE: \(Date())
        COMMAND: \(command)

        OUTPUT:
        \(output)

        ERROR:
        \(error)
        """
        logToFile(name: name, content: logContent)
    }
}

extension ThrowingTaskGroup {
    /// Ожидает завершения всех задач и пробрасывает ошибки, если они возникли.
    /// Помогает избежать предупреждений компилятора о неиспользуемом 'try' при пустом теле группы.
    public mutating func waitForAll() async throws {
        while try await next() != nil {}
    }
}
