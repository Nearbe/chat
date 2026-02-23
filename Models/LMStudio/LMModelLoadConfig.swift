// MARK: - Связь с документацией: LM Studio (Версия: main). Статус: Синхронизировано.
import Foundation

/// Результирующая конфигурация, примененная при загрузке модели в LM Studio.
struct LMModelLoadConfig: Codable {
    /// Итоговая длина контекста
    let contextLength: Int?

    /// Итоговый размер батча
    let evalBatchSize: Int?

    /// Статус использования Flash Attention
    let flashAttention: Bool?

    /// Количество экспертов
    let numExperts: Int?

    /// Статус выгрузки KV-кэша на видеокарту
    let offloadKVCacheToGPU: Bool?

    enum CodingKeys: String, CodingKey {
        case contextLength = "context_length"
        case evalBatchSize = "eval_batch_size"
        case flashAttention = "flash_attention"
        case numExperts = "num_experts"
        case offloadKVCacheToGPU = "offload_kv_cache_to_gpu"
    }
}
