import Foundation

/// Менеджер авторизации устройства
@MainActor
final class DeviceAuthManager {
    /// Текущее имя устройства
    var currentDeviceName: String {
        DeviceIdentity.currentName
    }

    /// Конфигурация текущего устройства
    private var deviceConfig: DeviceConfiguration? {
        DeviceConfiguration.configuration(for: currentDeviceName)
    }

    /// Авторизовано ли текущее устройство
    var isDeviceAuthorized: Bool {
        DeviceIdentity.isAuthorized
    }

    /// Получить токен для текущего устройства
    func getToken() -> String? {
        guard isDeviceAuthorized, let config = deviceConfig else { return nil }
        return KeychainHelper.get(key: config.tokenKey)
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
        guard let config = deviceConfig else { return false }
        return KeychainHelper.set(key: config.tokenKey, value: token)
    }

    /// Очистить токен (при 401/403)
    func clearToken() {
        guard let config = deviceConfig else { return }
        KeychainHelper.delete(key: config.tokenKey)
    }

    /// Получить цвет акцента для пользователя
    var accentColor: String {
        deviceConfig?.accentColorHex ?? "#007AFF"
    }

    /// Замаскированный токен для UI
    var maskedToken: String? {
        guard let token = getToken() else { return nil }
        let prefix = String(token.prefix(8))
        let suffix = token.count > 8 ? String(token.suffix(4)) : ""
        return "\(prefix):...\(suffix)"
    }
}
