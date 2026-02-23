// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import Foundation

/// - Спецификация OpenAI: [Docs/OpenAI/](../../Docs/OpenAI/)
/// - Совместимость LM Studio: [Docs/LMStudio/developer/openai-compat/](../../Docs/LMStudio/developer/openai-compat/)
/// Сообщение в формате API
struct ChatMessage: Codable, Hashable {
    let role: ChatRole
    let content: String
    let name: String?
    let toolCallId: String?

    enum CodingKeys: String, CodingKey {
        case role
        case content
        case name
        case toolCallId = "tool_call_id"
    }

    init(role: ChatRole, content: String, name: String? = nil, toolCallId: String? = nil) {
        self.role = role
        self.content = content
        self.name = name
        self.toolCallId = toolCallId
    }

    /// Создать сообщение из модели Message
    init(from message: Message) {
        switch message.role {
        case "user":
            self.role = .user
        case "assistant":
            self.role = .assistant
        case "tool":
            self.role = .tool
        default:
            self.role = .assistant
        }
        self.content = message.content
        self.name = nil
        // toolCallId может быть передан отдельно при необходимости
        self.toolCallId = nil
    }

    /// Сообщение пользователя
    static func user(_ content: String) -> ChatMessage {
        ChatMessage(role: .user, content: content)
    }

    /// Сообщение ассистента
    static func assistant(_ content: String) -> ChatMessage {
        ChatMessage(role: .assistant, content: content)
    }

    /// Сообщение системы
    static func system(_ content: String) -> ChatMessage {
        ChatMessage(role: .system, content: content)
    }

    /// Результат инструмента
    static func tool(content: String, toolCallId: String) -> ChatMessage {
        ChatMessage(role: .tool, content: content, toolCallId: toolCallId)
    }
}
