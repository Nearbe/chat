// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import Foundation

/// - Спецификация OpenAI: [Docs/OpenAI/](../../Docs/OpenAI/)
/// - Совместимость LM Studio: [Docs/LMStudio/developer/openai-compat/](../../Docs/LMStudio/developer/openai-compat/)
/// Запрос на создание чата
struct ChatCompletionRequest: Codable {
    let model: String
    let messages: [ChatMessage]
    let temperature: Double?
    let maxTokens: Int?
    let stream: Bool
    let tools: [ToolDefinition]?
    let toolChoice: String?

    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case temperature
        case maxTokens = "max_tokens"
        case stream
        case tools
        case toolChoice = "tool_choice"
    }

    init(
        model: String,
        messages: [ChatMessage],
        temperature: Double? = nil,
        maxTokens: Int? = nil,
        stream: Bool = false,
        tools: [ToolDefinition]? = nil,
        toolChoice: String? = nil
    ) {
        self.model = model
        self.messages = messages
        self.temperature = temperature
        self.maxTokens = maxTokens
        self.stream = stream
        self.tools = tools
        self.toolChoice = toolChoice
    }
}
