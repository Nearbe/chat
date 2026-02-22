import Foundation

/// Ответ загрузки модели
struct LMModelLoadResponse: Codable {
    let type: String
    let instanceId: String
    let loadTimeSeconds: Double
    let status: String
    let loadConfig: LMModelLoadConfig?

    enum CodingKeys: String, CodingKey {
        case type
        case instanceId = "instance_id"
        case loadTimeSeconds = "load_time_seconds"
        case status
        case loadConfig = "load_config"
    }
}
