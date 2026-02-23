// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import Foundation

public enum ShellError: Error, LocalizedError {
    case commandFailed(command: String, exitCode: Int32, output: String, error: String)
    case warningsFound(command: String, output: String)

    public var errorDescription: String? {
        switch self {
        case .commandFailed(let command, let exitCode, _, let error):
            return "Команда '\(command)' завершилась с кодом \(exitCode). Ошибка: \(error)"
        case .warningsFound(let command, _):
            return "Команда '\(command)' завершена с предупреждениями (warnings)."
        }
    }
}

public enum Shell {
    @discardableResult
    public static func run(
        _ command: String,
        workingDirectory: URL? = nil,
        environment: [String: String]? = nil,
        quiet: Bool = false,
        isInteractive: Bool = false,
        failOnWarnings: Bool = true,
        allowedWarnings: [String] = []
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
            failOnWarnings: failOnWarnings,
            allowedWarnings: allowedWarnings
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
        failOnWarnings: Bool,
        allowedWarnings: [String] = []
    ) async throws -> String {
        // Читаем из пайпов в параллельных задачах, чтобы избежать дедлоков при переполнении буферов
        async let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        async let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

        let finalOutputData = await outputData
        let finalErrorData = await errorData

        process.waitUntilExit()

        let output = String(data: finalOutputData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let error = String(data: finalErrorData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

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
}

extension ThrowingTaskGroup {
    /// Ожидает завершения всех задач и пробрасывает ошибки, если они возникли.
    /// Помогает избежать предупреждений компилятора о неиспользуемом 'try' при пустом теле группы.
    public mutating func waitForAll() async throws {
        while try await next() != nil {}
    }
}
