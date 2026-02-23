import Foundation

/// Протокол для предоставления данных авторизации
protocol AuthorizationProvider: Sendable {
    /// Возвращает значение заголовка Authorization
    func authorizationHeader() -> String?
}

/// Провайдер авторизации на основе настроек устройства и Keychain
struct DeviceAuthorizationProvider: AuthorizationProvider {
    func authorizationHeader() -> String? {
        if ProcessInfo.processInfo.arguments.contains("-auth") {
            return "Bearer sk-lm-test-token"
        }
        let tokenKey = DeviceConfiguration.configuration(for: DeviceIdentity.currentName)?.tokenKey ?? "auth_token_test"
        guard let token = KeychainHelper.get(key: tokenKey),
              !token.isEmpty else {
            return nil
        }
        return "Bearer \(token)"
    }
}
