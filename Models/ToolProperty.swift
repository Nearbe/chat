import Foundation

/// Свойство параметра инструмента
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
