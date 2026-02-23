import SwiftUI

/// Статус инструментов MCP
struct ToolsStatusView: View {
    let isEnabled: Bool

    var body: some View {
        Button {
            // Переключение через настройки
        } label: {
            Image(systemName: iconName)
                .foregroundStyle(iconColor)
                .overlay(alignment: .topTrailing) {
                    if !isEnabled {
                        Image(systemName: "slash")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(.orange)
                    }
                }
        }
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(isEnabled ? "Инструменты включены" : "Инструменты отключены")
    }

    private var iconName: String {
        isEnabled ? "wrench.and.screwdriver.fill" : "wrench.and.screwdriver"
    }

    private var iconColor: Color {
        if !isEnabled {
            return .secondary
        }
        return ThemeManager.successGreen
    }

    private var accessibilityLabel: String {
        "MCP Tools"
    }
}

#Preview {
    HStack(spacing: 20) {
        ToolsStatusView(isEnabled: true)
        ToolsStatusView(isEnabled: false)
    }
    .padding()
}
