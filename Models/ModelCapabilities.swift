import Foundation

/// Возможности модели
struct ModelCapabilities: Codable, Hashable {
    let vision: Bool?
    let trainedForToolUse: Bool?

    enum CodingKeys: String, CodingKey {
        case vision
        case trainedForToolUse = "trained_for_tool_use"
    }
}
