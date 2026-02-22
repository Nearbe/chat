import SwiftUI

/// Индикатор статуса
struct StatusIndicator: View {
    enum Status {
        case connected
        case disconnected
        case connecting
        case error
    }

    let status: Status

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var color: Color {
        switch status {
        case .connected:
            return .green
        case .disconnected:
            return .gray
        case .connecting:
            return .orange
        case .error:
            return .red
        }
    }

    private var text: String {
        switch status {
        case .connected:
            return "Подключено"
        case .disconnected:
            return "Не подключено"
        case .connecting:
            return "Подключение..."
        case .error:
            return "Ошибка"
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        StatusIndicator(status: .connected)
        StatusIndicator(status: .disconnected)
        StatusIndicator(status: .connecting)
        StatusIndicator(status: .error)
    }
    .padding()
}
