// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.

import ArgumentParser
import Foundation

/// Команда для регистрации агентов из папки Agents/ в системе навыков Qwen.
struct RegisterAgents: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Регистрация агентов в ~/.qwen/skills/",
        discussion: """
                    Сканирует папку Agents/ и создаёт навыки в ~/.qwen/skills/.
                    Каждый агент должен иметь файл SKILL.md с frontmatter.
                    """
    )

    func run() async throws {
        print("🤖 Регистрация агентов...")

        let agentsPath = Path.currentDirectory + "Agents"

        // Регистрируем всех агентов
        let registeredCount = try SkillRegistrar.registerAll(from: agentsPath)
        print("✅ Зарегистрировано агентов: \(registeredCount)")

        // Обновляем README.md
        _ = try ReadmeGenerator.generateAndWrite(to: agentsPath)
    }
}
