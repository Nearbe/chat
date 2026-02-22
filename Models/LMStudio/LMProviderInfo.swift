import Foundation

/// Provider info
struct LMProviderInfo: Codable {
    let type: String
    let pluginId: String?
    let serverLabel: String?

    enum CodingKeys: String, CodingKey {
        case type
        case pluginId = "plugin_id"
        case serverLabel = "server_label"
    }
}
