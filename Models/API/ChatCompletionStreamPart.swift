// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import Foundation

/// - Спецификация OpenAI: [Docs/OpenAI/](../../Docs/OpenAI/)
/// - Совместимость LM Studio: [Docs/LMStudio/developer/openai-compat/](../../Docs/LMStudio/developer/openai-compat/)
/// Часть ответа с инструментом
struct ChatCompletionStreamPart: Codable {
    let choices: [StreamChoice]
}
