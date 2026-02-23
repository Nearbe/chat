// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import SwiftUI

/// Статистика генерации
struct GenerationStatsView: View {
    let stats: GenerationStats

    var body: some View {
        HStack(spacing: 16) {
            statItem(
                icon: "bolt.fill",
                value: stats.formattedTokensPerSecond,
                label: "Скорость"
            )

            Divider()
                .frame(height: 24)

            statItem(
                icon: "number",
                value: "\(stats.totalTokens)",
                label: "Токенов"
            )

            Divider()
                .frame(height: 24)

            statItem(
                icon: "clock",
                value: stats.formattedTime,
                label: "Время"
            )

            Divider()
                .frame(height: 24)

            statItem(
                icon: "flag.checkered",
                value: stats.formattedStopReason,
                label: "Статус"
            )
        }
        .font(AppTypography.caption)
        .foregroundStyle(.secondary)
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.xs)
        .background(AppColors.backgroundTertiary)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func statItem(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(AppTypography.caption2)
                Text(value)
                    .font(AppTypography.caption)
                    .fontWeight(.medium)
            }
            Text(label)
                .font(AppTypography.caption2)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        GenerationStatsView(stats: GenerationStats(
            totalTokens: 150,
            tokensPerSecond: 42.5,
            generationTime: 3.5,
            stopReason: "stop"
        ))

        GenerationStatsView(stats: .empty)
    }
    .padding()
}
