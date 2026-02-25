// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.

import Foundation

/// Сервис для сканирования директории агентов.
/// Отвечает за обнаружение агентов в проекте.
struct AgentScanner {
    /// Сканирует папку Agents/ и возвращает список имён агентов
    /// - Parameter agentsPath: Путь к папке Agents
    /// - Returns: Массив имён агентов (без README.md и workspace)
    static func scan(agentsPath: Path) throws -> [String] {
        guard FileManager.default.fileExists(atPath: agentsPath.string) else {
            throw AgentScannerError.directoryNotFound(agentsPath.string)
        }

        return try FileManager.default.contentsOfDirectory(
            atPath: agentsPath.string
        ).filter {
            $0 != "README.md" && $0 != "workspace"
        }
    }

    /// Проверяет наличие SKILL.md для агента
    /// - Parameters:
    ///   - agentName: Имя агента
    ///   - agentsPath: Путь к папке Agents
    /// - Returns: Путь к SKILL.md или nil, если файл не существует
    static func skillFilePath(foragentName: String, inagentsPath: Path) -> Path? {
        let skillPath = agentsPath + agentName + "SKILL.md"
        return FileManager.default.fileExists(atPath: skillPath.string) ? skillPath: nil
    }
}

/// Ошибки сканера агентов
enum AgentScannerError: Error, LocalizedError {
    case directoryNotFound(String)

    var errorDescription: String? {
        switch self {
        case .directoryNotFound(let path):
            return "Директория агентов не найдена: \(path)"
        }
    }
}
