// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import Foundation

// MARK: - Результат выполнения шага проверки

/// Результат выполнения шага проверки (успех, предупреждение или ошибка).
enum CheckStepResult: Sendable {
    case success(step: String, duration: TimeInterval)
    case warning(step: String, command: String?, output: String, duration: TimeInterval)
    case failure(info: CheckStepFailureInfo)

    var duration: TimeInterval {
        switch self {
        case .success(_, let duration), .warning(_, _, _, let duration):
            return duration
        case .failure(let info):
            return info.duration
        }
    }
}

/// Информация об ошибке на конкретном шаге проверки.
struct CheckStepFailureInfo: Sendable, Error {
    let step: String
    let command: String?
    let output: String?
    let error: Error
    let duration: TimeInterval

    static func failure(
        step: String,
        command: String?,
        output: String?,
        error: Error,
        duration: TimeInterval
    ) -> CheckStepResult {
        .failure(info: CheckStepFailureInfo(
            step: step,
            command: command,
            output: output,
            error: error,
            duration: duration
        ))
    }
}

// MARK: - Ошибки проверки

/// Ошибки, специфичные для процесса проверки.
enum CheckError: Error, Sendable, LocalizedError {
    case coverageCheckFailed(String)
    case lowCoverage(target: String, actual: Double, expected: Double)

    var errorDescription: String? {
        switch self {
        case .coverageCheckFailed(let message):
            return "Ошибка проверки покрытия: \(message)"
        case .lowCoverage(let target, let actual, let expected):
            return "Низкое покрытие кода для \(target): \(String(format: "%.2f", actual))% (ожидается \(String(format: "%.2f", expected))%)"
        }
    }
}

// MARK: - Информация об изменённых файлах

/// Информация об изменённых файлах в репозитории.
struct ChangedFilesInfo: Sendable {
    let files: [String]
    let hasChanges: Bool

    static let empty = ChangedFilesInfo(files: [], hasChanges: false)
}
