import SwiftUI

/// Статус бадж - одна иконка с трансформацией
struct StatusBadgeView: View {
    let isConnected: Bool
    let isServerReachable: Bool
    let isModelSelected: Bool

    /// Текущая проблема (if any)
    private var currentStatus: (icon: String, color: Color, title: String, message: String, isActive: Bool)? {
        if !isConnected {
            return ("wifi.slash", .red, "Wi-Fi", "Нет подключения", false)
        }
        if !isServerReachable {
            return ("server.rack", .orange, "Сервер", "Не доступен", false)
        }
        if !isModelSelected {
            return ("cpu", .blue, "Модель", "Не выбрана", false)
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
                        .padding(.leading, 8)
                    
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
                    .padding(.leading, 8)
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
