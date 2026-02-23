// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import Foundation

extension ChatSession {
    /// Конвертировать сессию в Markdown формат
    func toMarkdown() -> String {
        var markdown = "# \(title)\n\n"
        markdown += "- **Дата**: \(createdAt.formatted())\n"
        markdown += "- **Модель**: \(modelName)\n\n"
        markdown += "---\n\n"

        for message in sortedMessages {
            let roleName = message.isUser ? "Пользователь" : "Ассистент"
            markdown += "### \(roleName)\n"

            if let reasoning = message.reasoning, !reasoning.isEmpty {
                markdown += "> **Рассуждения**:\n> \(reasoning.replacingOccurrences(of: "\n", with: "\n> "))\n\n"
            }

            markdown += "\(message.content)\n\n"
        }

        return markdown
    }
}
