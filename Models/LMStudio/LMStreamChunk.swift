import Foundation

/// Чанк стрима
struct LMStreamChunk: Codable {
    let type: String
    let content: String?
    let tool: String?
    let arguments: [String: AnyCodable]?
    let output: String?
    let stats: LMStats?

    enum CodingKeys: String, CodingKey {
        case type, content, tool, arguments, output, stats
    }

    var isMessage: Bool { type == "message" }
    var isReasoning: Bool { type == "reasoning" }
    var isToolCall: Bool { type == "tool_call" }
    var isDone: Bool { type == "done" }
}
