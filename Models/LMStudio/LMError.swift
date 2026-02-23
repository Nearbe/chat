// MARK: - Связь с документацией: LM Studio (Версия: main). Статус: Синхронизировано.
import Foundation

/// Ошибка, передаваемая в событиях LM Studio API.
struct LMError: Codable {
    /// Тип ошибки (например, "internal_server_error" или "invalid_request")
    let type: String?
    
    /// Текстовое описание ошибки
    let message: String?
    
    /// Код ошибки (если есть)
    let code: String?
    
    /// Параметр, вызвавший ошибку (например, имя аргумента)
    let param: String?
}
