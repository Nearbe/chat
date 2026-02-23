// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import SwiftUI

/// Строка сессии в истории чатов
struct SessionRowView: View {
    let session: ChatSession
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.title)
                        .font(AppTypography.headline)
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        Text(session.formattedDate)
                            .font(AppTypography.caption)
                            .foregroundStyle(.secondary)

                        Text("•")
                            .foregroundStyle(.secondary)
                            .accessibilityHidden(true)

                        Text("\(session.messageCount) сообщений")
                            .font(AppTypography.caption)
                            .foregroundStyle(.secondary)

                        if session.modelName != "default" {
                            Text("•")
                                .foregroundStyle(.secondary)
                                .accessibilityHidden(true)

                            Text(session.modelName)
                                .font(AppTypography.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(AppTypography.caption)
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Чат: \(session.title). \(session.messageCount) сообщений. Дата: \(session.formattedDate).")
        .accessibilityHint("Нажмите, чтобы открыть этот чат")
    }
}
