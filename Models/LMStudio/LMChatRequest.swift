import Foundation

/// Запрос на чат (LM Studio v1 API)
struct LMChatRequest: Codable {
    let model: String
    let input: LMInput
    let systemPrompt: String?
    let stream: Bool
    let temperature: Double?
    let topP: Double?
    let topK: Int?
    let minP: Double?
    let repeatPenalty: Double?
    let maxOutputTokens: Int?
    let reasoning: String?
    let contextLength: Int?
    let store: Bool?
    let previousResponseId: String?
    let integrations: [LMIntegration]?

    enum CodingKeys: String, CodingKey {
        case model
        case input
        case systemPrompt = "system_prompt"
        case stream
        case temperature
        case topP = "top_p"
        case topK = "top_k"
        case minP = "min_p"
        case repeatPenalty = "repeat_penalty"
        case maxOutputTokens = "max_output_tokens"
        case reasoning
        case contextLength = "context_length"
        case store
        case previousResponseId = "previous_response_id"
        case integrations
    }

    init(
        model: String,
        messages: [ChatMessage],
        systemPrompt: String? = nil,
        stream: Bool = true,
        temperature: Double? = nil,
        maxTokens: Int? = nil,
        reasoning: String? = nil,
        contextLength: Int? = nil,
        store: Bool = true,
        previousResponseId: String? = nil,
        integrations: [LMIntegration]? = nil
    ) {
        self.model = model
        self.input = LMInput(messages: messages)
        self.systemPrompt = systemPrompt
        self.stream = stream
        self.temperature = temperature
        self.topP = nil
        self.topK = nil
        self.minP = nil
        self.repeatPenalty = nil
        self.maxOutputTokens = maxTokens
        self.reasoning = reasoning
        self.contextLength = contextLength
        self.store = store
        self.previousResponseId = previousResponseId
        self.integrations = integrations
    }
}

/// Интеграция (MCP или плагин)
struct LMIntegration: Codable {
    let type: String
    let id: String?
    let serverLabel: String?
    let serverUrl: String?
    let allowedTools: [String]?
    let headers: [String: String]?

    enum CodingKeys: String, CodingKey {
        case type, id
        case serverLabel = "server_label"
        case serverUrl = "server_url"
        case allowedTools = "allowed_tools"
        case headers
    }
}
