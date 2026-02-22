import Foundation
import Security

/// Ошибки сети
enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(Int, String?)
    case unauthorized
    case forbidden
    case rateLimited(retryAfter: Int?)
    case networkError(Error)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Неверный URL"
        case .noData:
            return "Нет данных от сервера"
        case .decodingError(let error):
            return "Ошибка декодирования: \(error.localizedDescription)"
        case .serverError(let code, let message):
            return "Ошибка сервера \(code): \(message ?? "неизвестно")"
        case .unauthorized:
            return "Не авторизован (401)"
        case .forbidden:
            return "Доступ запрещён (403)"
        case .rateLimited(let retryAfter):
            if let seconds = retryAfter {
                return "Слишком много запросов. Повторите через \(seconds) сек."
            }
            return "Слишком много запросов"
        case .networkError(let error):
            return "Ошибка сети: \(error.localizedDescription)"
        case .unknown:
            return "Неизвестная ошибка"
        }
    }
}
