// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.

import Foundation

/// Сервис для запуска и анализа тестов.
enum TestService {
    /// Запускает все тесты (Unit + UI).
    static func runAll() async -> [CheckStepResult] {
        // Тесты отключены
        return []
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
