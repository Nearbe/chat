// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import Foundation

/// Статистика генерации ответа
struct GenerationStats: Equatable {
    let totalTokens: Int
    let tokensPerSecond: Double
    let generationTime: TimeInterval
    let stopReason: String?

    static let empty = GenerationStats(
        totalTokens: 0,
        tokensPerSecond: 0,
        generationTime: 0,
        stopReason: nil
    )

    var formattedTokensPerSecond: String {
        String(format: "%.1f т/с", tokensPerSecond)
    }

    var formattedTotalTokens: String {
        "\(totalTokens) токенов"
    }

    var formattedTime: String {
        if generationTime < 1 {
            return String(format: "%.0f мс", generationTime * 1000)
        } else if generationTime < 60 {
            return String(format: "%.1f с", generationTime)
        } else {
            let minutes = Int(generationTime) / 60
            let seconds = Int(generationTime) % 60
            return "\(minutes)м \(seconds)с"
        }
    }

    var formattedStopReason: String {
        guard let reason = stopReason else { return "—" }
        switch reason {
        case "stop":
            return "Завершено"
        case "length":
            return "Лимит токенов"
        case "content_filter":
            return "Фильтр контента"
        case "tool_calls":
            return "Вызов инструмента"
        default:
            return reason
        }
    }
}
