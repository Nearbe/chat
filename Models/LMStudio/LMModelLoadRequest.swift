import Foundation

/// Запрос на загрузку модели
struct LMModelLoadRequest: Codable {
    let model: String
    let contextLength: Int?
    let evalBatchSize: Int?
    let flashAttention: Bool?
    let numExperts: Int?
    let offloadKVCacheToGPU: Bool?
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
