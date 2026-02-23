import Foundation
import Security

/// Вспомогательная утилита для безопасного хранения данных в Keychain (Keychain Helper).
/// Позволяет сохранять, извлекать и удалять строковые значения (например, API-токены).
enum KeychainHelper {
    /// Получить строковое значение по ключу из Keychain.
    /// - Parameter key: Уникальный ключ (аккаунт) для поиска.
    /// - Returns: Сохраненная строка или nil, если данные не найдены или произошла ошибка.
    static func get(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    /// Сохранить или обновить строковое значение в Keychain по ключу.
    /// Использует уровень доступа "доступно при разблокированном устройстве, только для этого устройства".
    /// - Parameters:
    ///   - key: Ключ (аккаунт) для сохранения.
    ///   - value: Строка для сохранения.
    /// - Returns: true при успешном сохранении, иначе false.
    static func set(key: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        // Удаляем существующий элемент с этим ключом перед добавлением нового
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    /// Удалить значение из Keychain по указанному ключу.
    /// - Parameter key: Ключ для удаления.
    static func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
