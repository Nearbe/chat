import Foundation

/// Function в streaming tool call
struct StreamingFunction: Codable {
    let name: String?
    let arguments: String?
}
