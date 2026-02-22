import Foundation
import UIKit
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

/// Менеджер авторизации устройства
@MainActor
final class DeviceAuthManager {
    /// Разрешённые устройства
    private let allowedDevices: Set<String> = ["Saint Celestine", "Leonie"]

    /// Ключи токенов в Keychain
    private let tokenKeys: [String: String] = [
        "Saint Celestine": "auth_token_nearbe",
        "Leonie": "auth_token_kotya"
    ]

    /// Цвета акцента для пользователей
    private let accentColors: [String: String] = [
        "Saint Celestine": "#FF9F0A",
        "Leonie": "#007AFF"
    ]

    /// Текущее имя устройства
    var currentDeviceName: String {
        UIDevice.current.name
    }

    /// Авторизовано ли текущее устройство
    var isDeviceAuthorized: Bool {
        allowedDevices.contains(currentDeviceName)
    }

    /// Получить токен для текущего устройства
    func getToken() -> String? {
        guard isDeviceAuthorized else { return nil }
        guard let key = tokenKeys[currentDeviceName] else { return nil }
        return KeychainHelper.get(key: key)
    }

    /// Проверить авторизацию и вернуть результат
    func authenticate() -> Result<String, AuthError> {
        guard isDeviceAuthorized else {
            return .failure(.deviceNotAuthorized)
        }

        guard let token = getToken() else {
            return .failure(.tokenNotFound)
        }

        return .success(token)
    }

    /// Установить токен для устройства
    func setToken(_ token: String) -> Bool {
        guard let key = tokenKeys[currentDeviceName] else { return false }
        return KeychainHelper.set(key: key, value: token)
    }

    /// Очистить токен (при 401/403)
    func clearToken() {
        guard let key = tokenKeys[currentDeviceName] else { return }
        KeychainHelper.delete(key: key)
    }

    /// Получить цвет акцента для пользователя
    var accentColor: String {
        accentColors[currentDeviceName] ?? "#007AFF"
    }

    /// Замаскированный токен для UI
    var maskedToken: String? {
        guard let token = getToken() else { return nil }
        let prefix = String(token.prefix(8))
        let suffix = token.count > 8 ? String(token.suffix(4)) : ""
        return "\(prefix):...\(suffix)"
    }
}
