import Foundation

/// Ответ с результатами инструментов
struct ToolCallsResponse: Codable {
    let toolCalls: [ToolCallResult]

    enum CodingKeys: String, CodingKey {
        case toolCalls = "tool_calls"
    }
}
