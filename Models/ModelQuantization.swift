import Foundation

/// Информация о квантизации
struct ModelQuantization: Codable, Hashable {
    let name: String?
    let bitsPerWeight: Int?

    enum CodingKeys: String, CodingKey {
        case name
        case bitsPerWeight = "bits_per_weight"
    }
}
