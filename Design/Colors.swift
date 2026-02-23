import SwiftUI

// MARK: - Design System: Colors

/// Дизайн-система цветов приложения
@MainActor
enum AppColors {
    // MARK: - Primary Colors
    
    /// Основной оранжевый (Saint Celestine)
    static let primaryOrange = Asset.Assets.primaryOrange.swiftUIColor
    
    /// Основной синий (Leonie)
    static let primaryBlue = Asset.Assets.primaryBlue.swiftUIColor
    
    // MARK: - Semantic Colors
    
    /// Цвет успеха
    static let success = Asset.Assets.success.swiftUIColor
    
    /// Цвет ошибки
    static let error = Asset.Assets.error.swiftUIColor
    
    /// Цвет предупреждения
    static let warning = Asset.Assets.warning.swiftUIColor
    
    /// Цвет информационный
    static let info = Asset.Assets.info.swiftUIColor
    
    // MARK: - Neutral Colors
    
    /// Основной текст
    static let textPrimary = Color.primary
    
    /// Вторичный текст
    static let textSecondary = Color.secondary
    
    /// Третичный текст
    static let textTertiary = Color(uiColor: .tertiaryLabel)
    
    /// Фон основной
    static let backgroundPrimary = Color(uiColor: .systemBackground)
    
    /// Фон вторичный
    static let backgroundSecondary = Color(uiColor: .systemGroupedBackground)
    
    /// Фон третичный
    static let backgroundTertiary = Color(uiColor: .systemGray6)
    
    /// Разделитель
    static let separator = Color(uiColor: .separator)
    
    // MARK: - Status Colors
    
    /// Подключено
    static let connected = Color.green
    
    /// Отключено
    static let disconnected = Color.gray
    
    /// Ошибка подключения
    static let connectionError = Color.red
    
    /// Ожидание подключения
    static let connecting = Color.orange
}

// MARK: - Accent Color Helper

extension Color {
    /// Получить цвет акцента пользователя (обращаться через ThemeManager.shared.accentColor)
    static var accent: Color {
        Color.blue // Fallback - использовать ThemeManager.shared.accentColor в коде
    }
}
