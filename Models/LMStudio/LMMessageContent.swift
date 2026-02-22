import Foundation

/// Сообщение от модели
struct LMMessageContent: Codable {
    let type: String
    let content: String
}
