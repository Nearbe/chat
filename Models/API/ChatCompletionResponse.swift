import Foundation

/// Полный ответ чата (не streaming)
struct ChatCompletionResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [NonStreamChoice]
    let usage: Usage?
}

/// Non-stream выбор ответа
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

/// Usage статистика
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
