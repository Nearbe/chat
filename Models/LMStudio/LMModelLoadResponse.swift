// MARK: - Связь с документацией: LM Studio (Версия: main). Статус: Синхронизировано.
import Foundation

/// Ответ от LM Studio API на запрос загрузки модели.
struct LMModelLoadResponse: Codable {
    /// Тип ответа (всегда "model_load_response")
    let type: String
    
    /// Идентификатор созданного экземпляра модели
    let instanceId: String
    
    /// Время, затраченное на загрузку в секундах
    let loadTimeSeconds: Double
    
    /// Текущий статус (например, "loaded" или "failed")
    let status: String
    
    /// Примененная конфигурация загрузки (возвращается, если echoLoadConfig = true)
    let loadConfig: LMModelLoadConfig?

    enum CodingKeys: String, CodingKey {
        case type
        case instanceId = "instance_id"
        case loadTimeSeconds = "load_time_seconds"
        case status
        case loadConfig = "load_config"
    }
}
