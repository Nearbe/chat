// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.

import Foundation

/// Сервис для выполнения шагов проверки с измерением времени и обработкой ошибок.
enum StepExecutor {
    /// Выполняет шаг с измерением времени.
    static func execute(name: String,
    emoji: String,
    action: @escaping () async throws -> Void) async -> CheckStepResult {
        print("\(emoji)  Начало этапа: \(name)")
        let startTime = Date()

        do {
            try await Metrics.measure(step: name) {
                try await action()
            }
            let duration = Date().timeIntervalSince(startTime)
            print("🟢  Этап завершен: \(name) [\(String(format: "%.2fs", duration))]\n")
            return .success(step: name, duration: duration)
        } catch let error as ShellError {
            return handleShellError(error, name: name, startTime: startTime)
        } catch {
            return .failure(info: CheckStepFailureInfo(
                step: name,
                command: nil,
                output: nil,
                error: error,
                duration: Date().timeIntervalSince(startTime)
            ))
        }
    }

    private static func handleShellError(_ error: ShellError, name: String, startTime: Date) -> CheckStepResult {
        switch error {
        case .warningsFound(let command, let output):
            return .warning(
                step: name,
                command: command,
                output: output,
                duration: Date().timeIntervalSince(startTime)
            )
        case .commandFailed(let command, _, let output, let errorMsg):
            return .failure(info: CheckStepFailureInfo(
                step: name,
                command: command,
                output: "\(output)\n\(errorMsg)",
                error: error,
                duration: Date().timeIntervalSince(startTime)
            ))
        }
    }
}
