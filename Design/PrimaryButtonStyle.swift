// MARK: - Связь с документацией: SwiftGen (Версия: 6.6.3). Статус: Синхронизировано.
import SwiftUI

// MARK: - Primary Button Style

/// - Документация: [Docs/Codegen/SwiftGen/README.md](../Docs/Codegen/SwiftGen/README.md)
/// Кастомная кнопка с эффектом нажатия
struct PrimaryButtonStyle: ButtonStyle {
    let isDestructive: Bool

    init(isDestructive: Bool = false) {
        self.isDestructive = isDestructive
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTypography.callout.bold())
            .foregroundStyle(.white)
            .frame(minWidth: 80)
            .frame(height: 44)
            .padding(.horizontal, AppSpacing.md)
            .background(isDestructive ? AppColors.error : Color.accent)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Button Style Extensions

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }
    static var destructive: PrimaryButtonStyle { PrimaryButtonStyle(isDestructive: true) }
}
