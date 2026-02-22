import Foundation

/// Параметры инструмента
struct ToolParameters: Codable, Hashable {
    let type: String
    let properties: [String: ToolProperty]?
    let required: [String]?
}
