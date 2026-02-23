// MARK: - Связь с документацией: SwiftGen (Версия: 6.6.3). Статус: Синхронизировано.
import SwiftUI

// MARK: - Design System: Component Constants

/// - Документация: [Docs/Codegen/SwiftGen/README.md](../Docs/Codegen/SwiftGen/README.md)
/// Дизайн-система стилей компонентов (базовые константы)
@MainActor
enum AppComponentStyles {

    // MARK: - Button Styles

    /// Основная кнопка - цвет фона
    static var primaryButtonBackground: Color {
        Color.accent
    }

    /// Опасная кнопка - цвет фона
    static let destructiveButtonBackground = AppColors.error

    // MARK: - Card Styles

    /// Радиус пузыря сообщения
    static let bubbleRadius: CGFloat = 18

    /// Радиус инпута
    static let inputRadius: CGFloat = 18

    /// Радиус карточки
    static let cardRadius: CGFloat = 12

    /// Радиус кнопки
    static let buttonRadius: CGFloat = 8

    // MARK: - Input Styles

    /// Цвет границы текстового поля
    static let textFieldBorder = AppColors.systemGray4

    // MARK: - Status

    /// Статус - подключено
    static let statusConnected = AppColors.connected

    /// Статус - отключено
    static let statusDisconnected = AppColors.disconnected

    // MARK: - Icon Sizes

    /// Маленькая иконка
    static let iconSmall: CGFloat = 16

    /// Средняя иконка
    static let iconMedium: CGFloat = 24

    /// Большая иконка
    static let iconLarge: CGFloat = 32

    /// Очень большая иконка
    static let iconXLarge: CGFloat = 48

    /// Иконка статуса (индикатор)
    static let statusIcon: CGFloat = 10
}
