// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.

import SwiftUI

// MARK: - Вид статуса сервера

/// UI компонент для отображения и управления статусом LM Studio сервера
/// Показывает:
/// - Индикатор статуса (цветной кружок)
/// - Текстовое описание статуса
/// - Кнопку запуска/остановки сервера
/// - Сообщение об ошибке
struct ServerStatusView: View {

    // MARK: - Свойства (Properties)

    /// ViewModel с бизнес-логикой
    @Bindable var viewModel: ServerStatusViewModel

    // MARK: - Тело представления (Body)

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            // Статус индикатор и текст
            statusContent

            // Кнопка управления
            if shouldShowActionButton {
                actionButton
            }

            // Сообщение об ошибке
            if let errorMessage = viewModel.errorMessage {
                errorMessageView(errorMessage)
            }
        }.padding(AppSpacing.md)
    }

    // MARK: - Компоненты (Components)

    /// Контент статуса (индикатор + текст)
    private var statusContent: some View {
        HStack(spacing: AppSpacing.sm) {
            StatusIndicator(status: viewModel.status, isLoading: viewModel.isLoading)

            StatusText(status: viewModel.status)
        }
    }

    /// Индикатор статуса
    private struct StatusIndicator: View {
        let status: ServerStatus
        let isLoading: Bool

        var body: some View {
            Circle().fill(statusColor).frame(
                width: AppSpacing.statusIcon * 2,
                height: AppSpacing.statusIcon * 2
            ).overlay {
                if isLoading {
                    ProgressView().scaleEffect(0.6)
                }
            }.accessibilityElement(children: .ignore).accessibilityLabel(accessibilityLabel).accessibilityHint(accessibilityHint)
        }

        private var statusColor: Color {
            switch status {
            case .unknown:
                return AppColors.systemGray4
            case .starting:
                return AppColors.warning
            case .running:
                return AppColors.success
            case .stopping:
                return AppColors.warning
            case .unavailable:
                return AppColors.error
            }
        }

        private var accessibilityLabel: String {
            switch status {
            case .running:
                return "Сервер работает"
            case .starting:
                return "Запуск сервера"
            case .stopping:
                return "Остановка сервера"
            case .unavailable:
                return "Сервер недоступен"
            case .unknown:
                return "Статус неизвестен"
            }
        }

        private var accessibilityHint: String {
            switch status {
            case .running:
                return "Нажмите, чтобы остановить сервер"
            case .starting, .stopping:
                return "Ожидайте завершения операции"
            case .unavailable, .unknown:
                return "Нажмите, чтобы запустить сервер"
            }
        }
    }

    /// Текст статуса
    private struct StatusText: View {
        let status: ServerStatus

        var body: some View {
            Text(statusText).font(AppTypography.headline).foregroundStyle(AppColors.textPrimary).accessibilityElement(children: .ignore).accessibilityLabel(statusText)
        }

        private var statusText: String {
            switch status {
            case .unknown:
                return "Статус неизвестен"
            case .starting:
                return "Запуск сервера..."
            case .running:
                return "Сервер работает"
            case .stopping:
                return "Остановка сервера..."
            case .unavailable:
                return "Сервер недоступен"
            }
        }
    }

    /// Кнопка действия (запуск/остановка)
    private var actionButton: some View {
        Button {
            Task {
                await toggleServer()
            }
        } label: {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: buttonIcon)
                Text(buttonTitle)
            }.font(AppTypography.bodyBold).foregroundStyle(.white).frame(minWidth: AppSpacing.buttonMinWidth).frame(height: AppSpacing.buttonHeight).padding(.horizontal, AppSpacing.md).background(AppColors.primaryOrange).clipShape(RoundedRectangle(cornerRadius: AppSpacing.small))
        }.disabled(viewModel.isLoading).accessibilityElement(children: .ignore).accessibilityLabel(buttonTitle).accessibilityHint(buttonAccessibilityHint)
    }

    // MARK: - Вычисляемые свойства (Computed Properties)

    /// Показывать ли кнопку действия
    private var shouldShowActionButton: Bool {
        viewModel.status == .unavailable || viewModel.status == .unknown
    }

    /// Иконка кнопки
    private var buttonIcon: String {
        switch viewModel.status {
        case .unknown, .unavailable:
            return "play.fill"
        case .running:
            return "stop.fill"
        case .starting, .stopping:
            return "hourglass"
        }
    }

    /// Текст кнопки
    private var buttonTitle: String {
        switch viewModel.status {
        case .unknown, .unavailable:
            return "Запустить сервер"
        case .running:
            return "Остановить сервер"
        case .starting:
            return "Запуск..."
        case .stopping:
            return "Остановка..."
        }
    }

    /// Подсказка accessibility для кнопки
    private var buttonAccessibilityHint: String {
        switch viewModel.status {
        case .unknown, .unavailable:
            return "Запускает LM Studio сервер"
        case .running:
            return "Останавливает LM Studio сервер"
        case .starting, .stopping:
            return "Ожидайте завершения текущей операции"
        }
    }

    /// Переключение состояния сервера
    private func toggleServer() async {
        switch viewModel.status {
        case .unknown, .unavailable:
            await viewModel.startServer()
        case .running:
            await viewModel.stopServer()
        case .starting, .stopping:
            break
        }
    }

    /// Компонент отображения ошибки
    private func errorMessageView(_ message: String) -> some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(AppColors.error).font(AppTypography.caption)

            Text(message).font(AppTypography.caption).foregroundStyle(AppColors.error)
        }.padding(AppSpacing.sm).frame(maxWidth: .infinity, alignment: .leading).background(AppColors.error.opacity(0.1)).clipShape(RoundedRectangle(cornerRadius: AppSpacing.small)).accessibilityElement(children: .ignore).accessibilityLabel("Ошибка: \(message)")
    }
}

// MARK: - Превью

#Preview {
    ServerStatusView(viewModel: ServerStatusViewModel())
}
