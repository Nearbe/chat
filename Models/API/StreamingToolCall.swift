import Foundation

/// Tool call в streaming режиме
struct StreamingToolCall: Codable {
    let index: Int
    let id: String?
    let function: StreamingFunction?
}
