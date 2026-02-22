import Foundation

/// Delta для streaming ответа
struct ChatCompletionDelta: Codable {
    let role: ChatRole?
    let content: String?
    let toolCalls: [StreamingToolCall]?
    let reasoningContent: String?

    enum CodingKeys: String, CodingKey {
        case role
        case content
        case toolCalls = "tool_calls"
        case reasoningContent = "reasoning_content"
    }

    init(role: ChatRole? = nil, content: String? = nil, toolCalls: [StreamingToolCall]? = nil, reasoningContent: String? = nil) {
        self.role = role
        self.content = content
        self.toolCalls = toolCalls
        self.reasoningContent = reasoningContent
    }
}
