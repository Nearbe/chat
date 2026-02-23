// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import SwiftUI

/// Блок отображения "думания" AI
struct ThinkingBlock: View {
    @State private var dots: [Bool] = [true, false, false]

    let isThinking: Bool

    var body: some View {
        if isThinking {
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(ThemeManager.primaryOrange)
                        .frame(width: 6, height: 6)
                        .opacity(dots[index] ? 1 : 0.3)
                        .animation(
                            .easeInOut(duration: 0.4)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                            value: dots[index]
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(AppColors.systemGray5)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .frame(maxWidth: .infinity, alignment: .leading)
            .onAppear {
                dots = [true, true, true]
            }
            .accessibilityLabel("AI думает")
        }
    }
}

#Preview {
    VStack {
        ThinkingBlock(isThinking: true)
        ThinkingBlock(isThinking: false)
    }
    .padding()
}
