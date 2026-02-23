import Foundation

/// Текстовый контент сообщения от модели в ответе LM Studio.
struct LMMessageContent: Codable {
    /// Тип контента (всегда "message")
    let type: String
    
    /// Текст сообщения
    let content: String
}
