// MARK: - Связь с документацией: SwiftGen (Версия: 6.6.3). Статус: Синхронизировано.
import SwiftUI

// MARK: - Design System: Spacing

/// Дизайн-система отступов и размеров
enum AppSpacing {
    // MARK: - Base Spacing (8pt Grid)
    
    /// 4pt
    static let xxs: CGFloat = 4
    
    /// 8pt
    static let xs: CGFloat = 8
    
    /// 12pt
    static let sm: CGFloat = 12
    
    /// 16pt
    static let md: CGFloat = 16
    
    /// 24pt
    static let lg: CGFloat = 24
    
    /// 32pt
    static let xl: CGFloat = 32
    
    /// 48pt
    static let xxl: CGFloat = 48
    
    // MARK: - Component Specific
    
    /// Отступ сообщения по горизонтали
    static let messageHorizontal: CGFloat = 16
    
    /// Отступ сообщения по вертикали
    static let messageVertical: CGFloat = 12
    
    /// Расстояние между сообщениями
    static let messageSpacing: CGFloat = 8
    
    /// Отступ в input области
    static let inputPadding: CGFloat = 8
    
    /// Отступ в list
    static let listItemPadding: CGFloat = 12
    
    /// Padding секции в форме
    static let formSectionPadding: CGFloat = 16
    
    // MARK: - Corner Radius
    
    /// Маленький радиус (кнопки, поля ввода)
    static let small: CGFloat = 8
    
    /// Средний радиус (карточки, пузыри сообщений)
    static let medium: CGFloat = 12
    
    /// Большой радиус (модальные окна)
    static let large: CGFloat = 18
    
    /// Радиус пузыря сообщения
    static let bubbleRadius: CGFloat = 18
    
    /// Радиус инпута
    static let inputRadius: CGFloat = 18
    
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
    
    // MARK: - Button Sizes
    
    /// Высота кнопки
    static let buttonHeight: CGFloat = 44
    
    /// Минимальная ширина кнопки
    static let buttonMinWidth: CGFloat = 80
    
    // MARK: - Input Sizes
    
    /// Высота text field
    static let inputHeight: CGFloat = 44
    
    /// Минимальная высота text editor
    static let textEditorMinHeight: CGFloat = 100
    
    // MARK: - Animation
    
    /// Длительность короткой анимации
    static let animationFast: Double = 0.15
    
    /// Длительность стандартной анимации
    static let animationNormal: Double = 0.3
    
    /// Длительность длинной анимации
    static let animationSlow: Double = 0.5
}

// MARK: - View Extensions

extension View {
    /// Применить стандартные отступы
    func standardPadding() -> some View {
        self.padding(AppSpacing.md)
    }
    
    /// Применить отступы для контента
    func contentPadding() -> some View {
        self.padding(.horizontal, AppSpacing.messageHorizontal)
            .padding(.vertical, AppSpacing.xs)
    }
}
