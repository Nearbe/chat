import Foundation

/// Конфигурация загрузки модели
struct LMModelLoadConfig: Codable {
    let contextLength: Int?
    let evalBatchSize: Int?
    let flashAttention: Bool?
    let numExperts: Int?
    let offloadKVCacheToGPU: Bool?

    enum CodingKeys: String, CodingKey {
        case contextLength = "context_length"
        case evalBatchSize = "eval_batch_size"
        case flashAttention = "flash_attention"
        case numExperts = "num_experts"
        case offloadKVCacheToGPU = "offload_kv_cache_to_gpu"
    }
}
