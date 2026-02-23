import Foundation

/// - Спецификация OpenAI: [Docs/OpenAI/](../../Docs/OpenAI/)
/// - Совместимость LM Studio: [Docs/LMStudio/developer/openai-compat/](../../Docs/LMStudio/developer/openai-compat/)
/// Tool call в streaming режиме
struct StreamingToolCall: Codable {
    let index: Int
    let id: String?
    let function: StreamingFunction?
}
