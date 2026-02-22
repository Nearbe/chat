import Foundation

/// Ответ от /api/v1/models
struct LMModelsResponse: Codable {
    let models: [ModelInfo]
}
