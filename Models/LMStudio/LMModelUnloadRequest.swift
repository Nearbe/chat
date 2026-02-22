import Foundation

/// Запрос на выгрузку модели
struct LMModelUnloadRequest: Codable {
    let instanceId: String

    enum CodingKeys: String, CodingKey {
        case instanceId = "instance_id"
    }
}

/// Ответ выгрузки модели
struct LMModelUnloadResponse: Codable {
    let instanceId: String

    enum CodingKeys: String, CodingKey {
        case instanceId = "instance_id"
    }
}
