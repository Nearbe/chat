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
                        .font(.headline)
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        Text(session.formattedDate)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text("•")
                            .foregroundStyle(.secondary)
                            .accessibilityHidden(true)

                        Text("\(session.messageCount) сообщений")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        if session.modelName != "default" {
                            Text("•")
                                .foregroundStyle(.secondary)
                                .accessibilityHidden(true)

                            Text(session.modelName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
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
