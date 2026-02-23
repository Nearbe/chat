// MARK: - Связь с документацией: LM Studio (Версия: main). Статус: Синхронизировано.
import Foundation

/// Объект статистики генерации ответа от LM Studio.
/// Содержит метрики производительности и использования токенов.
struct LMStats: Codable {
    /// Количество токенов во входном запросе
    let inputTokens: Int

    /// Общее количество сгенерированных токенов (включая рассуждения)
    let totalOutputTokens: Int

    /// Количество токенов, затраченных на рассуждения (reasoning)
    let reasoningOutputTokens: Int?

    /// Скорость генерации в токенах в секунду
    let tokensPerSecond: Double?

    /// Время до генерации первого токена в секундах
    let timeToFirstTokenSeconds: Double?

    /// Время, затраченное на загрузку модели в секундах
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
