// MARK: - Связь с документацией: LM Studio (Версия: main). Статус: Синхронизировано.
import Foundation

/// Запрос на загрузку языковой модели в память (LM Studio API).
struct LMModelLoadRequest: Codable {
    /// ID модели для загрузки
    let model: String

    /// Ограничение контекстного окна в токенах
    let contextLength: Int?

    /// Размер батча для оценки
    let evalBatchSize: Int?

    /// Использовать ли технологию Flash Attention для ускорения
    let flashAttention: Bool?

    /// Количество экспертов (для MoE моделей)
    let numExperts: Int?

    /// Выгружать ли KV-кэш на видеокарту (GPU)
    let offloadKVCacheToGPU: Bool?

    /// Флаг возврата настроек загрузки в ответе сервера
    let echoLoadConfig: Bool

    enum CodingKeys: String, CodingKey {
        case model
        case contextLength = "context_length"
        case evalBatchSize = "eval_batch_size"
        case flashAttention = "flash_attention"
        case numExperts = "num_experts"
        case offloadKVCacheToGPU = "offload_kv_cache_to_gpu"
        case echoLoadConfig = "echo_load_config"
    }
}
