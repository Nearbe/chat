// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import Foundation

/// Информация об уровне и типе квантования модели (Quantization).
struct ModelQuantization: Codable, Hashable {
    /// Название метода квантования (например, "Q4_K_M")
    let name: String?
    
    /// Количество бит на один вес (например, 4)
    let bitsPerWeight: Int?

    enum CodingKeys: String, CodingKey {
        case name
        case bitsPerWeight = "bits_per_weight"
    }
}
