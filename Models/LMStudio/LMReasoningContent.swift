import Foundation

/// Контент рассуждений (reasoning/chain of thought) от модели в ответе LM Studio.
struct LMReasoningContent: Codable {
    /// Тип контента (всегда "reasoning")
    let type: String
    
    /// Текст рассуждений
    let content: String
}
