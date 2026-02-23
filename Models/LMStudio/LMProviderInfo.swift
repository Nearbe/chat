// MARK: - Связь с документацией: LM Studio (Версия: main). Статус: Синхронизировано.
import Foundation

/// Информация о провайдере инструмента (провайдер может быть плагином или MCP-сервером).
struct LMProviderInfo: Codable {
    /// Тип провайдера (например, "mcp" или "plugin")
    let type: String

    /// Идентификатор плагина (если применимо)
    let pluginId: String?

    /// Отображаемое имя (лейбл) сервера
    let serverLabel: String?

    enum CodingKeys: String, CodingKey {
        case type
        case pluginId = "plugin_id"
        case serverLabel = "server_label"
    }
}
