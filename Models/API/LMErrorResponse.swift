import Foundation

/// - Спецификация OpenAI: [Docs/OpenAI/](../../Docs/OpenAI/)
/// - Совместимость LM Studio: [Docs/LMStudio/developer/openai-compat/](../../Docs/LMStudio/developer/openai-compat/)
/// Ошибка API в формате LM Studio/OpenAI
struct LMErrorResponse: Codable {
    let error: LMError
}
