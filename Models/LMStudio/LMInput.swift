// MARK: - Связь с документацией: LM Studio (Версия: main). Статус: Синхронизировано.
import Foundation

/// Объект входных данных для LM Studio API.
/// Поддерживает как простую строку (prompt), так и структурированный массив сообщений (chat).
enum LMInput: Codable {
    /// Ввод в виде одной строки текста
    case string(String)

    /// Ввод в виде массива элементов (сообщений)
    case array([LMInputItem])

    /// Инициализация из массива сообщений ChatMessage
    init(messages: [ChatMessage]) {
        let items = messages.map { LMInputItem(message: $0) }
        self = .array(items)
    }

    /// Кодирование ввода в JSON
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let str):
            try container.encode(str)
        case .array(let items):
            try container.encode(items)
        }
    }

    /// Декодирование ввода из JSON (автоматически определяет тип: строка или массив)
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

/// Отдельный элемент входных данных в формате LM Studio.
struct LMInputItem: Codable {
    /// Тип элемента (например, "text")
    let type: String

    /// Содержимое элемента
    let content: String

    /// Инициализация из ChatMessage
    init(message: ChatMessage) {
        self.type = "text"
        self.content = message.content
    }

    /// Инициализация из простого текста
    init(text: String) {
        self.type = "text"
        self.content = text
    }
}
