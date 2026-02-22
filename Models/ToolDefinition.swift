import Foundation

/// Определение инструмента (tools) для MCP
struct ToolDefinition: Codable, Identifiable, Hashable {
    let type: String
    let function: FunctionDefinition

    var id: String { function.name }

    struct FunctionDefinition: Codable, Hashable {
        let name: String
        let description: String
        let parameters: ToolParameters?
    }

    struct ToolParameters: Codable, Hashable {
        let type: String
        let properties: [String: ToolProperty]?
        let required: [String]?
    }

    struct ToolProperty: Codable, Hashable {
        let type: String
        let description: String?
        let enumValues: [String]?

        enum CodingKeys: String, CodingKey {
            case type
            case description
            case enumValues = "enum"
        }
    }
}
