import Foundation

/// Error в событии
struct LMError: Codable {
    let type: String?
    let message: String?
    let code: String?
    let param: String?
}
