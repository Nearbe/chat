// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.

import Foundation

/// Сервис для запуска проверок стиля и качества кода.
enum LintService {
    /// Запускает все lint проверки.
    static func runAll() async -> [CheckStepResult] {
        print("🔍  Проверка стиля и структуры...")

        let swiftlint = await StepExecutor.execute(name: "SwiftLint", emoji: "🔍") {
            try await SwiftLintService.run()
        }

        let projectChecker = await StepExecutor.execute(name: "ProjectChecker", emoji: "📋") {
            try await ProjectChecker.run()
        }

        return [swiftlint, projectChecker]
    }
}
