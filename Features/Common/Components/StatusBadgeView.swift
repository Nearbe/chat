// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import SwiftUI

/// Статус бадж - одна иконка с трансформацией
struct StatusBadgeView: View {
    let isConnected: Bool
    let isServerReachable: Bool
    let isModelSelected: Bool

    private struct StatusInfo {
        let icon: String
        let color: Color
        let title: String
        let message: String
        let isActive: Bool
    }

    /// Текущая проблема (if any)
    private var currentStatus: StatusInfo? {
        if !isConnected {
            return StatusInfo(icon: "wifi.slash", color: .red, title: "Wi-Fi", message: "Нет подключения", isActive: false)
        }
        if !isServerReachable {
            return StatusInfo(icon: "server.rack", color: .orange, title: "Сервер", message: "Не доступен", isActive: false)
        }
        if !isModelSelected {
            return StatusInfo(icon: "cpu", color: .blue, title: "Модель", message: "Не выбрана", isActive: false)
        }
        return nil
    }

    var body: some View {
        if let status = currentStatus {
            StatusIcon(
                icon: status.icon,
                isActive: status.isActive,
                color: status.color,
                title: status.title,
                message: status.message
            )
        }
    }
}

/// Анимированная иконка статуса с popup
struct StatusIcon: View {
    let icon: String
    let isActive: Bool
    let color: Color
    let title: String
    let message: String

    @State private var pulse = false
    @State private var showPopover = false

    var body: some View {
        ZStack(alignment: .trailing) {
            // Пульсация
            if !isActive {
                HStack(spacing: 0) {
                    Text("\(title) - \(message)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.clear)
                        .padding(.leading, AppSpacing.xs)

                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.clear)
                }
                .padding(.horizontal, showPopover ? 4 : 0)
                .background(
                    Capsule()
                        .fill(color.opacity(0.2))
                        .frame(height: 36)
                )
                .frame(width: showPopover ? nil : 36, height: 36, alignment: .trailing)
                .animation(.easeInOut(duration: 0.3), value: showPopover)
                .scaleEffect(pulse ? 1.1 : 1.0)
                .opacity(pulse ? 0 : 1)
            }

            // Контент
            HStack(spacing: 0) {
                // Popup - выезжает из иконки
                Text("\(title) - \(message)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(color)
                    .padding(.leading, AppSpacing.xs)
                    .clipped()
                    .mask {
                        HStack(spacing: 0) {
                            Rectangle()
                                .fill(Color.white)
                                .frame(width: showPopover ? nil : 0)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                    .onTapGesture {
                        if showPopover {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showPopover = false
                            }
                        }
                    }

                // Иконка
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showPopover.toggle()
                    }
                } label: {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(color)
                        .frame(width: 36, height: 36)
                }
                .buttonStyle(.plain)
            }
        }
        .onAppear {
            if !isActive {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: false)) {
                    pulse = true
                }
            }
        }
        .onChange(of: isActive) { _, newValue in
            if !newValue {
                pulse = false
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: false)) {
                    pulse = true
                }
            } else {
                pulse = false
            }
        }
    }
}
