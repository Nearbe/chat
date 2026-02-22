import Foundation

/// Определение инструмента (tools) для MCP
struct ToolDefinition: Codable, Identifiable, Hashable {
    let type: String
    let function: FunctionDefinition

    var id: String { function.name }
}

/// Function определение внутри инструмента
struct FunctionDefinition: Codable, Hashable {
    let name: String
    let description: String
    let parameters: ToolParameters?
}
