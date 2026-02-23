import Foundation

/// Протокол для предоставления данных авторизации
protocol AuthorizationProvider: Sendable {
    /// Возвращает значение заголовка Authorization
    func authorizationHeader() -> String?
}

/// Провайдер авторизации на основе настроек устройства и Keychain
struct DeviceAuthorizationProvider: AuthorizationProvider {
    func authorizationHeader() -> String? {
        guard let config = DeviceConfiguration.configuration(for: DeviceIdentity.currentName),
              let token = KeychainHelper.get(key: config.tokenKey),
              !token.isEmpty else {
            return nil
        }
        return "Bearer \(token)"
    }
}
