// MARK: - Связь с документацией: LM Studio (Версия: main). Статус: Синхронизировано.
import Foundation

/// Метаданные вызова инструмента (tool call), содержащие имя и аргументы.
struct LMToolCallMetadata: Codable {
    /// Тип метаданных (всегда "tool_call_metadata")
    let type: String

    /// Имя вызываемого инструмента
    let toolName: String

    /// Аргументы вызова
    let arguments: [String: AnyCodable]?

    enum CodingKeys: String, CodingKey {
        case type
        case toolName = "tool_name"
        case arguments
    }
}
