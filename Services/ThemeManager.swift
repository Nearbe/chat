import SwiftUI

/// Менеджер темы приложения
@MainActor
final class ThemeManager: ObservableObject {
    /// Цвет акцента для текущего пользователя
    @Published var accentColor: Color

    /// Цветовая схема
    @Published var colorScheme: ColorScheme = .light

    private let authManager = DeviceAuthManager()

    static let shared = ThemeManager()

    private init() {
        self.accentColor = Color(hex: authManager.accentColor) ?? .blue
    }

    /// Обновить цвет акцента
    func updateAccentColor() {
        if let color = Color(hex: authManager.accentColor) {
            accentColor = color
        }
    }

    /// Переключить цветовую схему
    func toggleColorScheme() {
        colorScheme = colorScheme == .light ? .dark : .light
    }

    // MARK: - Цвета

    static let primaryOrange = Color(hex: "#FF9F0A")!
    static let primaryBlue = Color(hex: "#007AFF")!
    static let successGreen = Color(hex: "#34C759")!
    static let errorRed = Color(hex: "#FF3B30")!
    static let warningOrange = Color(hex: "#FF9500")!
}
