// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import Foundation
import Security

/// Перечисление возможных сетевых ошибок (Network Errors).
/// Соответствует протоколу LocalizedError для автоматического отображения сообщений в UI.
enum NetworkError: LocalizedError {
    /// Ошибка формирования URL
    case invalidURL
    
    /// Ответ от сервера не содержит данных
    case noData
    
    /// Ошибка преобразования JSON данных в Swift модели
    case decodingError(Error)
    
    /// Ошибка на стороне сервера с HTTP статус-кодом и сообщением
    case serverError(Int, String?)
    
    /// Ошибка авторизации (401 Unauthorized)
    case unauthorized
    
    /// Ошибка доступа (403 Forbidden)
    case forbidden
    
    /// Превышен лимит запросов (429 Rate Limited). Содержит время ожидания в секундах, если указано.
    case rateLimited(retryAfter: Int?)
    
    /// Общая ошибка сетевого соединения
    case networkError(Error)
    
    /// Непредвиденная или неизвестная ошибка
    case unknown

    /// Локализованное описание ошибки для пользователя.
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
