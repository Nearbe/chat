import SwiftUI

/// Отображение вызова инструмента
struct ToolCallView: View {
    let toolCall: ToolCall

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: iconName)
                .font(.caption)
                .foregroundStyle(iconColor)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 4) {
                Text("Инструмент: \(toolCall.name)")
                    .font(.caption)
                    .fontWeight(.medium)

                if toolCall.isExecuting {
                    HStack(spacing: 4) {
                        ProgressView()
                            .scaleEffect(0.5)
                        Text("Выполнение...")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                } else if let result = toolCall.result {
                    Text(result)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                } else if let error = toolCall.error {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(uiColor: .systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 8))

            Spacer()
        }
        .padding(.horizontal)
    }

    private var iconName: String {
        if toolCall.isExecuting {
            return "wrench.and.screwdriver"
        } else if toolCall.error != nil {
            return "exclamationmark.triangle"
        } else if toolCall.result != nil {
            return "checkmark.circle"
        }
        return "wrench.and.screwdriver"
    }

    private var iconColor: Color {
        if toolCall.isExecuting {
            return .orange
        } else if toolCall.error != nil {
            return .red
        } else if toolCall.result != nil {
            return .green
        }
        return .secondary
    }
}

#Preview {
    VStack(spacing: 8) {
        ToolCallView(toolCall: ToolCall(
            index: 0,
            name: "get_current_time",
            arguments: "{\"timezone\":\"Europe/Moscow\"}",
            isExecuting: true
        ))

        ToolCallView(toolCall: ToolCall(
            index: 1,
            name: "calculate",
            arguments: "{\"expression\":\"2+2*3\"}",
            result: "8",
            isExecuting: false
        ))
    }
    .padding()
}
