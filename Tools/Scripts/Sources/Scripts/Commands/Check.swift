// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import ArgumentParser
import MetricsCollector

/// Команда для выполнения технической проверки проекта.
struct Check: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Техническая проверка проекта (Lint + Build + Test)"
    )

    @Argument(help: "Сообщение для коммита")
    var message: String?

    func run() async throws {
        // Start metrics collection
        MetricsCollector.shared.start(operation: "check", scheme: "Check")

        let logger = try Log.start(logFileName: "CheckRun")
        Log.writeln("🚀  Начало технической проверки...")
        print()

        let results = try await CheckOrchestrator.run()

        guard !results.isEmpty else {
            MetricsCollector.shared.stop(exitCode: 0)
            return
        }

        let hasProblems = ResultPrinter.printSummary(results: results)

        if let logPath = logger.currentLogFilePath {
            ResultPrinter.printLogPath(logPath)
        }

        // Determine exit code and stop metrics
        let exitCode: Int
        if hasProblems {
            print()
            Log.writeln("❌  Техническая проверка не пройдена.")
            Log.stop()
            exitCode = 1
            MetricsCollector.shared.stop(exitCode: exitCode)
            throw ExitCode(1)
        }

        print()
        Log.writeln("✅  Техническая проверка успешно завершена!")
        Log.stop()
        exitCode = 0
        MetricsCollector.shared.stop(exitCode: exitCode)
    }
}
