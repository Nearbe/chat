import Foundation

/// Tool call
struct LMToolCall: Codable {
    let type: String
    let tool: String
    let arguments: [String: AnyCodable]?
    let output: String?
    let providerInfo: LMProviderInfo?

    enum CodingKeys: String, CodingKey {
        case type, tool, arguments, output
        case providerInfo = "provider_info"
    }
}
