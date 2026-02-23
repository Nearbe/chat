// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import Foundation

/// Информация о технических возможностях модели (Capabilities).
struct ModelCapabilities: Codable, Hashable {
    /// Поддержка компьютерного зрения (vision)
    let vision: Bool?
    
    /// Обучена ли модель для использования инструментов (function calling)
    let trainedForToolUse: Bool?

    enum CodingKeys: String, CodingKey {
        case vision
        case trainedForToolUse = "trained_for_tool_use"
    }
}
