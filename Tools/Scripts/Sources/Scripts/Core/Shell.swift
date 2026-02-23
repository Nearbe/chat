// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import Foundation

public enum ShellError: Error, LocalizedError {
    case commandFailed(command: String, exitCode: Int32, output: String, error: String)

    public var errorDescription: String? {
        switch self {
        case .commandFailed(let command, let exitCode, _, let error):
            return "Команда '\(command)' завершилась с кодом \(exitCode). Ошибка: \(error)"
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
        isInteractive: Bool = false
    ) async throws -> String {
        if !quiet {
            print("▶️  Запуск: \(command)")
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-c", command]

        if let workingDirectory = workingDirectory {
            process.currentDirectoryURL = workingDirectory
        }

        if let environment = environment {
            process.environment = ProcessInfo.processInfo.environment.merging(environment) { (_, new) in new }
        }

        let outputPipe = Pipe()
        let errorPipe = Pipe()

        if isInteractive {
            // Если мы хотим интерактивности, лучше не переопределять стандартные потоки,
            // чтобы процесс наследовал их напрямую от родителя.
            // Это наиболее надежный способ для работы sudo внутри swift run.
        } else {
            process.standardOutput = outputPipe
            process.standardError = errorPipe
        }

        try process.run()
        process.waitUntilExit()

        if isInteractive {
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

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

        let output = String(data: outputData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let error = String(data: errorData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

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
}

extension ThrowingTaskGroup {
    /// Ожидает завершения всех задач и пробрасывает ошибки, если они возникли.
    /// Помогает избежать предупреждений компилятора о неиспользуемом 'try' при пустом теле группы.
    public mutating func waitForAll() async throws {
        while try await next() != nil {}
    }
}
