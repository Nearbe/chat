// MARK: - Связь с документацией: LM Studio (Версия: main). Статус: Синхронизировано.
import Foundation

/// Объект, описывающий некорректный вызов инструмента (например, ошибка парсинга на стороне сервера).
struct LMInvalidToolCall: Codable {
    /// Тип ошибки (всегда "invalid_tool_call")
    let type: String
    
    /// Причина, по которой вызов признан некорректным
    let reason: String
    
    /// Доступные метаданные (имя инструмента, аргументы), если их удалось извлечь
    let metadata: LMToolCallMetadata?
}
