// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.

import Foundation

/// Сервис для генерации README.md для агентов.
/// Создаёт таблицу агентов с их описанием и правами доступа.
struct ReadmeGenerator {
    /// Информация об агенте для README
    struct AgentInfo {
        let name: String
        let description: String
        let access: String
    }

    /// Генерирует README.md на основе списка агентов
    /// - Parameter agents: Массив информации об агентах
    /// - Returns: Сгенерированный markdown контент
    static func generate(agents: [AgentInfo]) -> String {
        var md = """
                 # Агенты проекта Chat

                 Данная директория содержит автономных агентов, которые помогают разрабатывать iOS-приложение Chat.

                 """

        md += "| Агент | Описание | Доступ |\n"
        md += "|-------|----------|--------|\n"

        for agent in agents {
            let escapedDesc = agent.description.replacingOccurrences(of: "|", with: "\\|")
            md += "| **\(agent.name)** | \(escapedDesc) | \(agent.access) |\n"
        }

        md += """

              ## Использование

              Каждый агент активируется через skill system. Для запуска агента используйте соответствующий навык.

              ## Рабочие директории

              Каждый агент имеет рабочую директорию в `Agents/{agent-name}/workspace/` для хранения документации и заметок.

              ## Добавление нового агента

              Для создания нового агента используйте HR агента:

              ```
              Используйте skill "HR" и попросите "создать нового агента для [роль]"
              ```
              """

        return md
    }

    /// Сканирует агентов и генерирует README.md
    /// - Parameter agentsPath: Путь к папке Agents
    /// - Returns: Количество обработанных агентов
    static func generateAndWrite(to agentsPath: Path) throws -> Int {
        print("📝 Обновление README.md...")

        let agentNames = try AgentScanner.scan(agentsPath: agentsPath)
        var agents: [AgentInfo] = []

        for agentName in agentNames {
            guard let skillPath = AgentScanner.skillFilePath(for: agentName, in: agentsPath) else {
                continue
            }

            let content = try String(contentsOfFile: skillPath.string, encoding: .utf8)
            let parsed = SkillFileParser.parse(content: content)

            let access = extractAccess(from: content)
            let name = parsed.name.isEmpty ? formatAgentName(agentName): parsed.name

            agents.append(AgentInfo(name: name, description: parsed.description, access: access))
        }

        let readme = generate(agents: agents)
        let readmePath = agentsPath + "README.md"
        try readme.write(toFile: readmePath.string, atomically: true, encoding: .utf8)

        print("✅ Обновлён README.md с \(agents.count) агентами")
        return agents.count
    }

    /// Извлекает права доступа из контента
    private static func extractAccess(from content: String) -> String {
        if content.contains("Полный доступ") {
            return "Полный"
        } else if content.contains("только чтение") || content.contains("Чтение") {
            return "Чтение"
        }
        return "—"
    }

    /// Форматирует имя папки в читаемое название
    private static func formatAgentName(_ folderName: String) -> String {
        folderName.replacingOccurrences(of: "-", with: " ").capitalized
    }
}
