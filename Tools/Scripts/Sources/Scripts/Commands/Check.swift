// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import ArgumentParser

/// Команда для выполнения технической проверки проекта.
struct Check: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Техническая проверка проекта (Lint + Build + Test)"
    )

    @Argument(help: "Сообщение для коммита")
    var message: String?

    func run() async throws {
        let logger = try Log.start(logFileName: "CheckRun")
        Log.writeln("🚀  Начало технической проверки...")
        print()

        let results = try await CheckOrchestrator.run()

        guard !results.isEmpty else {
            return
        }

        let hasProblems = ResultPrinter.printSummary(results: results)

        if let logPath = logger.currentLogFilePath {
            ResultPrinter.printLogPath(logPath)
        }

        if hasProblems {
            print()
            Log.writeln("❌  Техническая проверка не пройдена.")
            Log.stop()
            throw ExitCode(1)
        }

        print()
        Log.writeln("✅  Техническая проверка успешно завершена!")
        Log.stop()
    }
}
