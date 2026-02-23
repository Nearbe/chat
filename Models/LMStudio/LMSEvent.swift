// MARK: - Связь с документацией: LM Studio (Версия: main). Статус: Синхронизировано.
import Foundation

/// Обобщенное событие Server-Sent Events (SSE) в протоколе LM Studio.
/// Используется для передачи данных стриминга чата, загрузки моделей и т.д.
struct LMSEvent: Codable {
    /// Тип события (например, "message.delta", "reasoning.delta", "tool_call.start", "error", "done")
    let type: String

    /// Текстовый контент (для сообщений и рассуждений)
    let content: String?

    /// Имя инструмента (для событий начала вызова инструмента)
    let tool: String?

    /// Аргументы инструмента (для событий передачи аргументов)
    let arguments: [String: AnyCodable]?

    /// Текстовый вывод/результат инструмента
    let output: String?

    /// Информация о провайдере (для инструментов)
    let providerInfo: LMProviderInfo?

    /// Ошибка, если тип события — "error"
    let error: LMError?

    /// Полный объект ответа (иногда передается в конце чата)
    let result: LMChatResponse?

    /// Прогресс выполнения (например, для скачивания или загрузки)
    let progress: Double?

    enum CodingKeys: String, CodingKey {
        case type, content, tool, arguments, output
        case providerInfo = "provider_info"
        case error, result, progress
    }
}
