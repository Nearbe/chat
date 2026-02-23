// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import Foundation

/// Ответ с результатами инструментов
struct ToolCallsResponse: Codable {
    let toolCalls: [ToolCallResult]

    enum CodingKeys: String, CodingKey {
        case toolCalls = "tool_calls"
    }
}
