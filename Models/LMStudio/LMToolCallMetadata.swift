import Foundation

/// Tool call metadata
struct LMToolCallMetadata: Codable {
    let type: String
    let toolName: String
    let arguments: [String: AnyCodable]?

    enum CodingKeys: String, CodingKey {
        case type
        case toolName = "tool_name"
        case arguments
    }
}
