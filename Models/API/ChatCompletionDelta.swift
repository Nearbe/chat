// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import Foundation

/// - Спецификация OpenAI: [Docs/OpenAI/](../../Docs/OpenAI/)
/// - Совместимость LM Studio: [Docs/LMStudio/developer/openai-compat/](../../Docs/LMStudio/developer/openai-compat/)
/// Delta для streaming ответа
struct ChatCompletionDelta: Codable {
    let role: ChatRole?
    let content: String?
    let toolCalls: [StreamingToolCall]?
    let reasoningContent: String?

    enum CodingKeys: String, CodingKey {
        case role
        case content
        case toolCalls = "tool_calls"
        case reasoningContent = "reasoning_content"
    }

    init(role: ChatRole? = nil, content: String? = nil, toolCalls: [StreamingToolCall]? = nil, reasoningContent: String? = nil) {
        self.role = role
        self.content = content
        self.toolCalls = toolCalls
        self.reasoningContent = reasoningContent
    }
}
