import Foundation

/// Invalid tool call
struct LMInvalidToolCall: Codable {
    let type: String
    let reason: String
    let metadata: LMToolCallMetadata?
}
