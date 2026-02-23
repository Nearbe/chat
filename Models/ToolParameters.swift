// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import Foundation

/// Параметры инструмента
struct ToolParameters: Codable, Hashable {
    let type: String
    let properties: [String: ToolProperty]?
    let required: [String]?
}
