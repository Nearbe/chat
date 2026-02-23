import Foundation

/// Утилита для идентификации текущего устройства (Device Identity)
/// Позволяет получить нормализованное имя хоста и проверить статус авторизации.
struct DeviceIdentity: Sendable {
    /// Получить нормализованное имя устройства.
    /// Преобразует системное имя хоста (например, "MacBook-Pro.local") в читаемый формат ("Macbook Pro").
    /// Используется для сопоставления с DeviceConfiguration.
    static var currentName: String {
        let rawName = ProcessInfo.processInfo.hostName
        let normalized = rawName
            .replacingOccurrences(of: ".local", with: "")
            .replacingOccurrences(of: "-", with: " ")
            .trimmingCharacters(in: .whitespaces)
            .split(separator: " ")
            .map { $0.prefix(1).uppercased() + $0.dropFirst().lowercased() }
            .joined(separator: " ")
        return normalized
    }

    /// Проверить, является ли текущее устройство авторизованным в системе.
    /// Возвращает true, если для хостнейма устройства найдена соответствующая конфигурация.
    static var isAuthorized: Bool {
        if ProcessInfo.processInfo.arguments.contains("-auth") {
            return true
        }
        return DeviceConfiguration.configuration(for: currentName) != nil
    }
}
