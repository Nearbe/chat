// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
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

    // MARK: - Backward Compatibility (используйте AppColors)

    /// Основной оранжевый (для совместимости)
    static let primaryOrange = AppColors.primaryOrange
    
    /// Основной синий (для совместимости)
    static let primaryBlue = AppColors.primaryBlue
    
    /// Успех (для совместимости)
    static let successGreen = AppColors.success
    
    /// Ошибка (для совместимости)
    static let errorRed = AppColors.error
    
    /// Предупреждение (для совместимости)
    static let warningOrange = AppColors.warning
}
