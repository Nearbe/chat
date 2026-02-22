import Foundation

/// Утилита для определения текущего устройства
struct DeviceIdentity: Sendable {
    /// Получить нормализованное имя устройства
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

    /// Проверить, авторизовано ли текущее устройство
    static var isAuthorized: Bool {
        DeviceConfiguration.configuration(for: currentName) != nil
    }
}
