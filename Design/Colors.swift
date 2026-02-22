import SwiftUI

// MARK: - Design System: Colors

/// Дизайн-система цветов приложения
enum AppColors {
    // MARK: - Primary Colors
    
    /// Основной оранжевый (Saint Celestine)
    static let primaryOrange = Color(hex: "#FF9F0A") ?? .orange
    
    /// Основной синий (Leonie)
    static let primaryBlue = Color(hex: "#007AFF") ?? .blue
    
    // MARK: - Semantic Colors
    
    /// Цвет успеха
    static let success = Color(hex: "#34C759") ?? .green
    
    /// Цвет ошибки
    static let error = Color(hex: "#FF3B30") ?? .red
    
    /// Цвет предупреждения
    static let warning = Color(hex: "#FF9500") ?? .orange
    
    /// Цвет информационный
    static let info = Color(hex: "#5AC8FA") ?? .cyan
    
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
