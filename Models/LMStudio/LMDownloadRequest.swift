// MARK: - Связь с документацией: LM Studio (Версия: main). Статус: Синхронизировано.
import Foundation

/// Запрос на скачивание модели из публичного репозитория в LM Studio.
struct LMDownloadRequest: Codable {
    /// Путь к модели (например, "lmstudio-community/qwen2.5-7b-instruct-gguf")
    let model: String

    /// Опциональный уровень квантования (если не указан, скачивается версия по умолчанию)
    let quantization: String?

    /// Инициализация запроса на скачивание
    init(model: String, quantization: String? = nil) {
        self.model = model
        self.quantization = quantization
    }
}
