import Foundation

/// Объект ответа от LM Studio API на запрос списка доступных моделей (/api/v1/models).
struct LMModelsResponse: Codable {
    /// Массив объектов ModelInfo с информацией о каждой модели
    let models: [ModelInfo]
}
