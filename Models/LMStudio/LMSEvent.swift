import Foundation

/// SSE событие (для стриминга)
struct LMSEvent: Codable {
    let type: String
    let content: String?
    let tool: String?
    let arguments: [String: AnyCodable]?
    let output: String?
    let providerInfo: LMProviderInfo?
    let error: LMError?
    let result: LMChatResponse?
    let progress: Double?

    enum CodingKeys: String, CodingKey {
        case type, content, tool, arguments, output
        case providerInfo = "provider_info"
        case error, result, progress
    }
}
