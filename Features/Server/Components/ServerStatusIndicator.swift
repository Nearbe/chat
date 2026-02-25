import SwiftUI

/// Упрощённый индикатор статуса сервера для toolbar
struct ServerStatusIndicator: View {
    let status: ServerStatus

    var body: some View {
        Circle().fill(statusColor).frame(width: 12, height: 12)
    }

    private var statusColor: Color {
        switch status {
        case .unknown:
            return AppColors.disconnected
        case .starting:
            return AppColors.connecting
        case .running:
            return AppColors.connected
        case .stopping:
            return AppColors.connecting
        case .unavailable:
            return AppColors.connectionError
        }
    }
}
