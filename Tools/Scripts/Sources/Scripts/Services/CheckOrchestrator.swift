// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.

import Foundation

/// Оркестратор для координации всех этапов проверки.
enum CheckOrchestrator {
    /// Выполняет полную проверку.
    static func run() async throws -> [CheckStepResult] {
        let changedFilesInfo = try await GitService.getChangedFiles()

        if !changedFilesInfo.hasChanges {
            ResultPrinter.printNoChanges()
            return []
        }

        ResultPrinter.printChangedFiles(changedFilesInfo.files)

        var results: [CheckStepResult] = []
        results += await LintService.runAll()
        results += await InfrastructureService.runFull()
        results += await TestService.runAll()

        return results
    }
}
