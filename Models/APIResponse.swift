import Foundation

/// Типы сообщений для OpenAI API
enum ChatRole: String, Codable {
    case system
    case user
    case assistant
    case tool
}

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

/// Delta для streaming ответа
struct ChatCompletionDelta: Codable {
    let role: ChatRole?
    let content: String?
    let toolCalls: [StreamingToolCall]?

    enum CodingKeys: String, CodingKey {
        case role
        case content
        case toolCalls = "tool_calls"
    }
}

/// Tool call в streaming режиме
struct StreamingToolCall: Codable {
    let index: Int
    let id: String?
    let function: StreamingFunction?
}

/// Function в streaming tool call
struct StreamingFunction: Codable {
    let name: String?
    let arguments: String?
}

/// Часть ответа с инструментом
struct ChatCompletionStreamPart: Codable {
    let choices: [StreamChoice]
}

/// Выбор в streaming ответе
struct StreamChoice: Codable {
    let index: Int
    let delta: ChatCompletionDelta
    let finishReason: String?

    enum CodingKeys: String, CodingKey {
        case index
        case delta
        case finishReason = "finish_reason"
    }
}

/// Полный ответ чата (не streaming)
struct ChatCompletionResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [NonStreamChoice]
    let usage: Usage?

    struct NonStreamChoice: Codable {
        let index: Int
        let message: ChatMessage
        let finishReason: String?

        enum CodingKeys: String, CodingKey {
            case index
            case message
            case finishReason = "finish_reason"
        }
    }

    struct Usage: Codable {
        let promptTokens: Int?
        let completionTokens: Int?
        let totalTokens: Int?

        enum CodingKeys: String, CodingKey {
            case promptTokens = "prompt_tokens"
            case completionTokens = "completion_tokens"
            case totalTokens = "total_tokens"
        }
    }
}
