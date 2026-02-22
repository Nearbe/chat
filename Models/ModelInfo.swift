import Foundation

/// Информация о доступной модели с LM Studio (v1 API)
struct ModelInfo: Codable, Identifiable, Hashable {
    let id: String
    let type: String?
    let publisher: String?
    let displayName: String?
    let architecture: String?
    let quantization: ModelQuantization?
    let sizeBytes: Int64?
    let paramsString: String?
    let maxContextLength: Int?
    let format: String?
    let capabilities: ModelCapabilities?
    let description: String?

    enum CodingKeys: String, CodingKey {
        case id = "key"
        case type
        case publisher
        case displayName = "display_name"
        case architecture
        case quantization
        case sizeBytes = "size_bytes"
        case paramsString = "params_string"
        case maxContextLength = "max_context_length"
        case format
        case capabilities
        case description
    }

    /// Convenience initializer для превью
    init(id: String, displayName: String? = nil) {
        self.id = id
        self.type = nil
        self.publisher = nil
        self.displayName = displayName
        self.architecture = nil
        self.quantization = nil
        self.sizeBytes = nil
        self.paramsString = nil
        self.maxContextLength = nil
        self.format = nil
        self.capabilities = nil
        self.description = nil
    }

    /// ID модели (используется для API)
    var modelId: String {
        id
    }

    /// Отображаемое имя модели
    var name: String {
        displayName ?? id.replacingOccurrences(of: "lmstudio-community/", with: "")
            .replacingOccurrences(of: "ollama/", with: "")
    }
}
