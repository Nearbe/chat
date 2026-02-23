// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import SwiftUI

/// Визуальный индикатор статуса сетевого подключения.
/// Отображает цветной круг и текстовое описание состояния.
struct StatusIndicator: View {
    /// Возможные состояния подключения
    enum Status {
        case connected    /// Успешно подключено
        case disconnected /// Подключение отсутствует
        case connecting   /// В процессе установки соединения
        case error        /// Произошла ошибка при подключении
    }

    /// Текущий статус для отображения
    let status: Status

    var body: some View {
        HStack(spacing: 6) {
            // Маленький индикаторный круг
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            // Текстовое описание статуса
            Text(text)
                .font(AppTypography.caption)
                .foregroundStyle(.secondary)
        }
    }

    /// Выбор цвета индикатора на основе статуса
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

    /// Выбор локализованного текста на основе статуса
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
