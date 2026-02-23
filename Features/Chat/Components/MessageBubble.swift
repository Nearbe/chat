// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import SwiftUI

/// Пузырь сообщения в чате
struct MessageBubble: View {
    let message: Message
    let onDelete: () -> Void
    let onEdit: (String) -> Void

    @State private var isEditing = false
    @State private var editedContent = ""
    @Environment(\.colorScheme) private var colorScheme

    private var isUser: Bool {
        message.role == "user"
    }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if isUser { Spacer(minLength: 40) }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(AppTypography.body)
                    .foregroundStyle(.primary)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: isUser ? .trailing : .leading)

                HStack(spacing: 4) {
                    if let modelName = message.modelName, !message.isUser {
                        Text(modelName)
                            .font(AppTypography.caption2)
                            .foregroundStyle(.secondary)
                    }

                    Text(message.createdAt.formatted(date: .omitted, time: .shortened))
                        .font(AppTypography.caption2)
                        .foregroundStyle(.secondary)

                    if message.isGenerating {
                        ProgressView()
                            .scaleEffect(0.6)
                    }
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.messageVertical)
            .background(isUser ? ThemeManager.shared.accentColor : AppColors.systemGray5)
            .foregroundStyle(isUser ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .frame(maxWidth: .infinity, alignment: isUser ? .trailing : .leading)

            if !isUser { Spacer(minLength: 40) }
        }
        .contextMenu {
            Button {
                UIPasteboard.general.string = message.content
            } label: {
                Label("Копировать", systemImage: "doc.on.doc")
            }

            if isUser {
                Button {
                    editedContent = message.content
                    isEditing = true
                } label: {
                    Label("Редактировать", systemImage: "pencil")
                }
            }

            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Удалить", systemImage: "trash")
            }
        }
        .sheet(isPresented: $isEditing) {
            editView
        }
    }

    private var editView: some View {
        NavigationStack {
            VStack {
                TextEditor(text: $editedContent)
                    .padding()
            }
            .navigationTitle("Редактирование")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        isEditing = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        onEdit(editedContent)
                        isEditing = false
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    VStack {
        MessageBubble(
            message: Message.user(content: "Привет! Как дела?", sessionId: UUID(), index: 0),
            onDelete: {},
            onEdit: { _ in }
        )

        MessageBubble(
            message: Message.assistant(content: "Привет! Я — AI ассистент. Чем могу помочь?", sessionId: UUID(), index: 1),
            onDelete: {},
            onEdit: { _ in }
        )
    }
    .padding()
}
