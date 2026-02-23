// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import Foundation

/// Конфигурация разрешённых устройств (Device Configuration)
/// Хранит данные для аутентификации и стилизации UI для конкретных устройств.
struct DeviceConfiguration: Sendable {
    /// Имя устройства (хостнейм), по которому оно идентифицируется
    let name: String

    /// Ключ, по которому API-токен сохраняется и извлекается из Keychain
    let tokenKey: String

    /// Hex-код акцентного цвета для оформления интерфейса на данном устройстве
    let accentColorHex: String

    /// Список всех авторизованных (разрешённых) устройств
    /// Новые устройства должны быть добавлены сюда для корректной работы приложения.
    static let allowed: [DeviceConfiguration] = [
        DeviceConfiguration(
            name: "Saint Celestine",
            tokenKey: "auth_token_nearbe",
            accentColorHex: "#FF9F0A"
        ),
        DeviceConfiguration(
            name: "Leonie",
            tokenKey: "auth_token_kotya",
            accentColorHex: "#007AFF"
        )
    ]

    /// Поиск конфигурации по имени устройства
    /// - Parameter deviceName: Нормализованное имя устройства
    /// - Returns: Конфигурация устройства или nil, если устройство не найдено
    static func configuration(for deviceName: String) -> DeviceConfiguration? {
        allowed.first { $0.name == deviceName }
    }
}
