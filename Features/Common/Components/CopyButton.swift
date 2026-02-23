// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import SwiftUI

/// Кнопка копирования в буфер обмена
struct CopyButton: View {
    let text: String

    @State private var showCopied = false

    var body: some View {
        Button {
            UIPasteboard.general.string = text
            showCopied = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showCopied = false
            }
        } label: {
            Image(systemName: showCopied ? "checkmark" : "doc.on.doc")
                .font(AppTypography.caption)
                .foregroundStyle(showCopied ? .green : .secondary)
        }
        .accessibilityLabel("Копировать")
    }
}

#Preview {
    CopyButton(text: "Hello, World!")
        .padding()
}
