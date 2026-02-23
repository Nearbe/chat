// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import Foundation
import Security

/// Ошибки авторизации
enum AuthError: LocalizedError {
    case deviceNotAuthorized
    case tokenNotFound
    case keychainError(OSStatus)

    var errorDescription: String? {
        switch self {
        case .deviceNotAuthorized:
            return "Устройство не авторизовано. Добавьте токен в Настройки."
        case .tokenNotFound:
            return "Токен не найден в Keychain"
        case .keychainError(let status):
            return "Ошибка Keychain: \(status)"
        }
    }
}
