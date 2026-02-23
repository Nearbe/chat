import Foundation
import Security

// MARK: - Менеджер авторизации устройства (Device Authorization Manager)

/// Управляет сохранением и получением токена авторизации из Keychain.
/// Использует уникальный ключ для каждого устройства.
///
/// Принцип работы:
/// - Токен сохраняется в Keychain под уникальным ключом устройства
/// - При запуске проверяется наличие токена
/// - Токен передаётся в HTTP заголовках при каждом запросе
///
/// Безопасность:
/// - Keychain обеспечивает шифрование данных
/// - Токен не хранится в UserDefaults (небезопасно)
/// - Каждое устройство имеет свой токен
///
/// - Важно: Уникальный ключ определяется через DeviceConfiguration
/// - Примечание: Токены должны начинаться с "sk-lm" для LM Studio
final class DeviceAuthManager {
    
    // MARK: - Приватные свойства (Private Properties)
    
    /// Ключ для хранения в Keychain
    /// Определяется для каждого устройства отдельно
    private let tokenKey: String
    
    // MARK: - Инициализация (Initialization)
    
    /// Инициализация менеджера
    /// Определяет ключ токена для текущего устройства
    init() {
        // Получаем ключ из конфигурации устройства
        // Если устройство неизвестно - используем пустой ключ
        self.tokenKey = DeviceConfiguration.configuration(for: DeviceIdentity.currentName)?.tokenKey ?? ""
    }

    // MARK: - Публичные методы (Public Methods)
    
    /// Сохранить токен авторизации
    /// - Parameter token: API токен для сохранения
    /// - Важно: Токен сохраняется в зашифрованном Keychain
    func setToken(_ token: String) {
        // Проверяем что ключ определён
        guard !tokenKey.isEmpty else { return }
        
        // Сохраняем через KeychainHelper
        KeychainHelper.save(key: tokenKey, value: token)
    }
    
    /// Получить токен авторизации
    /// - Returns: Сохранённый токен или nil если не найден
    func getToken() -> String? {
        // Проверяем что ключ определён
        guard !tokenKey.isEmpty else { return nil }
        
        // Получаем через KeychainHelper
        return KeychainHelper.load(key: tokenKey)
    }
    
    /// Удалить токен авторизации
    /// Используется при выходе или смене аккаунта
    func deleteToken() {
        guard !tokenKey.isEmpty else { return }
        KeychainHelper.delete(key: tokenKey)
    }
    
    /// Проверить наличие токена
    /// - Returns: true если токен сохранён
    var hasToken: Bool {
        getToken() != nil
    }
}
