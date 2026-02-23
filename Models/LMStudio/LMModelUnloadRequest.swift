import Foundation

/// Запрос на выгрузку (освобождение памяти) модели из LM Studio.
struct LMModelUnloadRequest: Codable {
    /// Идентификатор экземпляра модели, который нужно выгрузить
    let instanceId: String

    enum CodingKeys: String, CodingKey {
        case instanceId = "instance_id"
    }
}

/// Ответ от сервера, подтверждающий выгрузку модели.
struct LMModelUnloadResponse: Codable {
    /// Идентификатор выгруженного экземпляра модели
    let instanceId: String

    enum CodingKeys: String, CodingKey {
        case instanceId = "instance_id"
    }
}
