import Foundation

/// Запрос на скачивание модели
struct LMDownloadRequest: Codable {
    let model: String
    let quantization: String?

    init(model: String, quantization: String? = nil) {
        self.model = model
        self.quantization = quantization
    }
}
