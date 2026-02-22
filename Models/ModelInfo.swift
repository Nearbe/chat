import Foundation

/// Информация о доступной модели с LM Studio
struct ModelInfo: Codable, Identifiable, Hashable {
    let id: String
    let object: String
    let created: Int?
    let ownedBy: String?

    enum CodingKeys: String, CodingKey {
        case id
        case object
        case created
        case ownedBy = "owned_by"
    }

    init(id: String, object: String = "model", created: Int? = nil, ownedBy: String? = nil) {
        self.id = id
        self.object = object
        self.created = created
        self.ownedBy = ownedBy
    }

    /// Отображаемое имя модели
    var displayName: String {
        id.replacingOccurrences(of: "ollama/", with: "")
            .replacingOccurrences(of: "lmstudio/", with: "")
    }
}

/// Ответ от /v1/models
struct ModelsResponse: Codable {
    let object: String
    let data: [ModelInfo]
}
