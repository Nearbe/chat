// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import Foundation

/// Результат выполнения инструмента
struct ToolCallResult: Codable {
    let toolCallId: String
    let result: String

    enum CodingKeys: String, CodingKey {
        case toolCallId = "tool_call_id"
        case result
    }
}
