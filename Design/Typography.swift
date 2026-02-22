import SwiftUI

// MARK: - Design System: Typography

/// Дизайн-система типографики
enum AppTypography {
    // MARK: - Headlines
    
    /// largeTitle - для главных заголовков
    static let largeTitle = Font.largeTitle.bold()
    
    /// title - для заголовков секций
    static let title = Font.title.bold()
    
    /// title2 - для подзаголовков
    static let title2 = Font.title2
    
    /// title3 - для малых заголовков
    static let title3 = Font.title3
    
    // MARK: - Body
    
    /// body - основной текст
    static let body = Font.body
    
    /// bodyBold - жирный основной текст
    static let bodyBold = Font.body.bold()
    
    /// bodySmall - уменьшенный основной текст
    static let bodySmall = Font.body
    
    // MARK: - Callout
    
    /// callout - для подписей
    static let callout = Font.callout
    
    /// calloutBold - жирный callout
    static let calloutBold = Font.callout.bold()
    
    // MARK: - Caption
    
    /// caption - подписи
    static let caption = Font.caption
    
    /// captionBold - жирные подписи
    static let captionBold = Font.caption.bold()
    
    /// caption2 - малые подписи
    static let caption2 = Font.caption2
    
    // MARK: - Special
    
    /// message - текст сообщения
    static let message = Font.body
    
    /// timestamp - время сообщения
    static let timestamp = Font.caption2
    
    /// modelName - имя модели
    static let modelName = Font.caption2
    
    /// input - текст ввода
    static let input = Font.body
}

// MARK: - View Modifiers

/// Модификатор для стиля заголовка
struct TitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(AppTypography.title)
            .foregroundStyle(AppColors.textPrimary)
    }
}

/// Модификатор для стиля подзаголовка
struct SubtitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(AppTypography.callout)
            .foregroundStyle(AppColors.textSecondary)
    }
}

/// Модификатор для стиля сообщения
struct MessageStyle: ViewModifier {
    let isUser: Bool
    
    func body(content: Content) -> some View {
        content
            .font(AppTypography.message)
            .foregroundStyle(isUser ? .white : AppColors.textPrimary)
    }
}

/// Модификатор для timestamp
struct TimestampStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(AppTypography.timestamp)
            .foregroundStyle(AppColors.textSecondary)
    }
}

extension View {
    /// Применить стиль заголовка
    func titleStyle() -> some View {
        modifier(TitleStyle())
    }
    
    /// Применить стиль подзаголовка
    func subtitleStyle() -> some View {
        modifier(SubtitleStyle())
    }
    
    /// Применить стиль сообщения
    func messageStyle(isUser: Bool) -> some View {
        modifier(MessageStyle(isUser: isUser))
    }
    
    /// Применить стиль timestamp
    func timestampStyle() -> some View {
        modifier(TimestampStyle())
    }
}
