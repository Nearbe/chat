import Foundation

/// Типы сообщений для OpenAI API
enum ChatRole: String, Codable {
    case system
    case user
    case assistant
    case tool
}
