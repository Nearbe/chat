import Foundation

/// Статистика
struct LMStats: Codable {
    let inputTokens: Int
    let totalOutputTokens: Int
    let reasoningOutputTokens: Int?
    let tokensPerSecond: Double?
    let timeToFirstTokenSeconds: Double?
    let modelLoadTimeSeconds: Double?

    enum CodingKeys: String, CodingKey {
        case inputTokens = "input_tokens"
        case totalOutputTokens = "total_output_tokens"
        case reasoningOutputTokens = "reasoning_output_tokens"
        case tokensPerSecond = "tokens_per_second"
        case timeToFirstTokenSeconds = "time_to_first_token_seconds"
        case modelLoadTimeSeconds = "model_load_time_seconds"
    }
}
