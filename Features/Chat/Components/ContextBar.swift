// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import SwiftUI

/// Контекстный бар (мета-информация о чате)
struct ContextBar: View {
    let messageCount: Int
    let modelName: String?
    let isGenerating: Bool

    var body: some View {
        HStack(spacing: 12) {
            if isGenerating {
                HStack(spacing: 4) {
                    ProgressView()
                        .scaleEffect(0.6)
                    Text("Генерация...")
                        .font(AppTypography.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "bubble.left.and.bubble.right")
                    .font(AppTypography.caption2)
                Text("\(messageCount)")
                    .font(AppTypography.caption)
            }
            .foregroundStyle(.secondary)

            if let model = modelName {
                Text("•")
                    .foregroundStyle(.tertiary)

                Text(model)
                    .font(AppTypography.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .font(AppTypography.caption)
    }
}

#Preview {
    VStack(spacing: 16) {
        ContextBar(messageCount: 5, modelName: "llama-3.2-3b", isGenerating: false)
        ContextBar(messageCount: 10, modelName: "qwen-2.5-7b", isGenerating: true)
    }
    .padding()
}
