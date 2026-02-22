import SwiftUI

/// Экран выбора модели
struct ModelPicker: View {
    @Environment(\.dismiss) private var dismiss

    let models: [ModelInfo]
    @Binding var selectedModel: String

    var body: some View {
        NavigationStack {
            Group {
                if models.isEmpty {
                    emptyStateView
                } else {
                    modelsListView
                }
            }
            .navigationTitle("Выбор модели")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "cpu")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("Модели не найдены")
                .font(.headline)

            Text("Убедитесь, что LM Studio запущен")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var modelsListView: some View {
        List(models, id: \.id) { model in
            Button {
                selectedModel = model.id
                dismiss()
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(model.displayName)
                            .font(.headline)
                            .foregroundStyle(.primary)

                        if let ownedBy = model.ownedBy {
                            Text(ownedBy)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    if model.id == selectedModel {
                        Image(systemName: "checkmark")
                            .foregroundStyle(ThemeManager.shared.accentColor)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .listStyle(.insetGrouped)
    }
}

#Preview {
    ModelPicker(
        models: [
            ModelInfo(id: "llama-3.2-3b-instruct", ownedBy: "meta"),
            ModelInfo(id: "qwen-2.5-7b", ownedBy: "alibaba")
        ],
        selectedModel: .constant("llama-3.2-3b-instruct")
    )
}
