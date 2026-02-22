import Foundation

/// Input для LM Studio API (может быть строкой или массивом)
enum LMInput: Codable {
    case string(String)
    case array([LMInputItem])

    init(messages: [ChatMessage]) {
        let items = messages.map { LMInputItem(message: $0) }
        self = .array(items)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let str):
            try container.encode(str)
        case .array(let items):
            try container.encode(items)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let str = try? container.decode(String.self) {
            self = .string(str)
        } else if let items = try? container.decode([LMInputItem].self) {
            self = .array(items)
        } else {
            throw DecodingError.typeMismatch(LMInput.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Invalid input type"))
        }
    }
}

/// Элемент ввода (сообщение)
struct LMInputItem: Codable {
    let type: String
    let content: String

    init(message: ChatMessage) {
        self.type = "text"
        self.content = message.content
    }

    init(text: String) {
        self.type = "text"
        self.content = text
    }
}
