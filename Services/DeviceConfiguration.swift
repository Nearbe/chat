import Foundation

/// Конфигурация разрешённых устройств
struct DeviceConfiguration: Sendable {
    /// Имя устройства
    let name: String

    /// Ключ токена в Keychain
    let tokenKey: String

    /// Цвет акцента для UI
    let accentColorHex: String

    /// Все разрешённые устройства
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
    static func configuration(for deviceName: String) -> DeviceConfiguration? {
        allowed.first { $0.name == deviceName }
    }
}
