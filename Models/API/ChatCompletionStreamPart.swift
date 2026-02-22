import Foundation

/// Часть ответа с инструментом
struct ChatCompletionStreamPart: Codable {
    let choices: [StreamChoice]
}
