import Foundation

/// Объект ответа от чат-интерфейса LM Studio v1 API.
/// Содержит сгенерированный контент, статистику и метаданные ответа.
struct LMChatResponse: Codable {
    /// Внутренний идентификатор экземпляра модели, обработавшей запрос
    let modelInstanceId: String
    
    /// Массив элементов вывода (сообщения, вызовы инструментов, рассуждения)
    let output: [LMOutputItem]
    
    /// Статистика генерации (токены, скорость, время)
    let stats: LMStats?
    
    /// Уникальный идентификатор данного ответа
    let responseId: String

    enum CodingKeys: String, CodingKey {
        case modelInstanceId = "model_instance_id"
        case output
        case stats
        case responseId = "response_id"
    }
}

/// Перечисление возможных типов элементов вывода в ответе LM Studio.
/// Позволяет обрабатывать смешанный контент (текст + вызовы инструментов).
enum LMOutputItem: Codable {
    /// Обычное текстовое сообщение
    case message(LMMessageContent)
    
    /// Вызов внешнего инструмента (function calling)
    case toolCall(LMToolCall)
    
    /// Внутренние рассуждения модели (chain of thought)
    case reasoning(LMReasoningContent)
    
    /// Некорректный вызов инструмента (ошибка парсинга на стороне сервера)
    case invalidToolCall(LMInvalidToolCall)

    enum CodingKeys: String, CodingKey {
        case type
    }

    /// Декодирование элемента вывода на основе поля "type".
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let msg = try? container.decode(LMMessageContent.self), msg.type == "message" {
            self = .message(msg)
        } else if let toolCall = try? container.decode(LMToolCall.self), toolCall.type == "tool_call" {
            self = .toolCall(toolCall)
        } else if let reasoning = try? container.decode(LMReasoningContent.self), reasoning.type == "reasoning" {
            self = .reasoning(reasoning)
        } else if let invalid = try? container.decode(LMInvalidToolCall.self), invalid.type == "invalid_tool_call" {
            self = .invalidToolCall(invalid)
        } else {
            throw DecodingError.typeMismatch(LMOutputItem.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unknown output type"))
        }
    }

    /// Кодирование элемента вывода.
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .message(let msg):
            try container.encode(msg)
        case .toolCall(let call):
            try container.encode(call)
        case .reasoning(let reasoning):
            try container.encode(reasoning)
        case .invalidToolCall(let invalid):
            try container.encode(invalid)
        }
    }

    /// Извлечение текстового содержимого элемента (если применимо).
    var content: String {
        switch self {
        case .message(let msg):
            return msg.content
        case .toolCall(let call):
            return call.output ?? ""
        case .reasoning(let reasoning):
            return reasoning.content
        case .invalidToolCall:
            return ""
        }
    }

    /// Вспомогательное свойство для получения вызова инструмента, если элемент является таковым.
    var toolCall: LMToolCall? {
        if case .toolCall(let call) = self {
            return call
        }
        return nil
    }
}
