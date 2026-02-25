// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.

import Foundation

/// Сервис для запуска и анализа тестов.
enum TestService {
    /// Путь к Python скрипту локального веб-сервера для UI тестов.
    private static let pythonServerScriptPath = "/Users/nearbe/repositories/Chat/ChatUITests/Utils/Network/AutotestsLocalWebServer.py"

    /// Порт для Python веб-сервера.
    private static let pythonServerPort = 63281

    /// Таймаут ожидания запуска сервера (секунды).
    private static let serverStartupTimeout: UInt64 = 2_000_000_000
    // 2 секунды в наносекундах

    /// Запускает Python веб-сервер для UI тестов.
    private static func startPythonServer() async throws {
        let portArg = String(pythonServerPort)
        _ = try await Shell.runBackground(
            "python3 \(pythonServerScriptPath) \(portArg)",
            name: "AutotestsLocalWebServer"
        )
        // Даем серверу время запуститься
        try await Task.sleep(nanoseconds: serverStartupTimeout)
        print("✅  Python веб-сервер запущен на порту \(pythonServerPort)")
    }

    /// Останавливает Python веб-сервер.
    private static func stopPythonServer() async {
        // Сервер останавливается автоматически при завершении процесса
        // Но для явной остановки используем pkill
        _ = try ? await Shell.run("pkill -f AutotestsLocalWebServer.py", quiet: true)
        print("🛑  Python веб-сервер остановлен")
    }

    /// Запускает все тесты (Unit + UI).
    static func runAll() async -> [CheckStepResult] {
        // Запускаем Python веб-сервер перед тестами
        do {
            try await startPythonServer()
        } catch {
            print("⚠️  Не удалось запустить Python веб-сервер: \(error)")
        }

        // Запускаем тесты
        let result = await runTests()

        // Останавливаем Python веб-сервер после тестов
        await stopPythonServer()

        return [result]
    }

    /// Запускает все тесты.
    private static func runTests() async -> CheckStepResult {
        await StepExecutor.execute(name: "All Tests", emoji: "🧪") {
            let result = try await TestRunner.runAllTests()
            try? await TestRunner.checkCoverage(
                resultBundlePath: result.resultPath,
                targetName: "Chat",
                expected: 50.0
            )
        }
    }
}
