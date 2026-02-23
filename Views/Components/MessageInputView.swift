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
                    .padding(.bottom, 16)
                }
                .frame(height: 52)
                .padding(.trailing, 16)
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
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.clear)
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(AppColors.systemGray4, lineWidth: 1)
                )
                .accessibilityLabel("Ввод сообщения")
                .accessibilityHint("Введите текст сообщения")

            sendButton
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
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
                .font(.system(size: 32))
                .foregroundStyle(isGenerating ? .red : ThemeManager.shared.accentColor)
        }
        .disabled(!isGenerating && (inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty 
                                    || !isServerReachable || selectedModel.isEmpty))
        .opacity(isGenerating || (!inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty 
                                  && isServerReachable && !selectedModel.isEmpty) ? 1.0 : 0.5)
        .accessibilityLabel(isGenerating ? "Остановить генерацию" : "Отправить сообщение")
    }
}
