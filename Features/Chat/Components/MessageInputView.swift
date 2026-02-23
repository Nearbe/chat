// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import SwiftUI

/// Область ввода сообщения
struct MessageInputView: View {
    @Binding var inputText: String
    let isAuthenticated: Bool
    let isGenerating: Bool
    let isServerReachable: Bool
    let selectedModel: String
    let onSend: () async -> Void
    let onStop: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Статус-бар
            if isAuthenticated {
                HStack(alignment: .bottom) {
                    Spacer()
                    StatusBadgeView(
                        isConnected: true,
                        isServerReachable: isServerReachable,
                        isModelSelected: !selectedModel.isEmpty
                    )
                    .padding(.bottom, AppSpacing.md)
                }
                .frame(height: 52)
                .padding(.trailing, AppSpacing.md)
                .background(AppColors.backgroundPrimary)
            }

            // Поле ввода
            if isAuthenticated {
                inputField
            }
        }
    }

    private var inputField: some View {
        HStack(alignment: .bottom, spacing: 8) {
            TextField("Сообщение...", text: $inputText, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(1...10)
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, AppSpacing.xs)
                .background(Color.clear)
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(AppColors.systemGray4, lineWidth: 1)
                )
                .accessibilityLabel("Ввод сообщения")
                .accessibilityHint("Введите текст сообщения")
                .accessibilityIdentifier("message_input_field")

            sendButton
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.bottom, AppSpacing.xs)
    }

    private var sendButton: some View {
        Button {
            if isGenerating {
                onStop()
            } else {
                Task {
                    await onSend()
                }
            }
        } label: {
            Image(systemName: isGenerating ? "stop.fill" : "arrow.up.circle.fill")
                .font(AppTypography.iconMedium)
                .foregroundStyle(isGenerating ? .red : ThemeManager.shared.accentColor)
        }
        .disabled(!isGenerating && (inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                    || !isServerReachable || selectedModel.isEmpty))
        .opacity(isGenerating || (!inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                  && isServerReachable && !selectedModel.isEmpty) ? 1.0 : 0.5)
        .accessibilityLabel(isGenerating ? "Остановить генерацию" : "Отправить сообщение")
        .accessibilityIdentifier("send_button")
    }
}
