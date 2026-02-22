import Foundation

/// Ответ чата (LM Studio v1 API)
struct LMChatResponse: Codable {
    let modelInstanceId: String
    let output: [LMOutputItem]
    let stats: LMStats?
    let responseId: String

    enum CodingKeys: String, CodingKey {
        case modelInstanceId = "model_instance_id"
        case output
        case stats
        case responseId = "response_id"
    }
}

/// Элемент вывода
enum LMOutputItem: Codable {
    case message(LMMessageContent)
    case toolCall(LMToolCall)
    case reasoning(LMReasoningContent)
    case invalidToolCall(LMInvalidToolCall)

    enum CodingKeys: String, CodingKey {
        case type
    }

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

    var toolCall: LMToolCall? {
        if case .toolCall(let call) = self {
            return call
        }
        return nil
    }
}
