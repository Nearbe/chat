import Foundation
import Pulse

/// Конфигурация сетевого сервиса (Network Configuration)
/// Определяет параметры сессии, таймауты и инструменты кодирования/декодирования.
struct NetworkConfiguration: Sendable {
    /// URLSession для выполнения запросов
    let session: URLSession
    
    /// Декодер для преобразования JSON в Swift модели
    let decoder: JSONDecoder
    
    /// Энкодер для преобразования Swift моделей в JSON
    let encoder: JSONEncoder
    
    /// Таймаут запроса в секундах
    let timeout: TimeInterval

    /// Стандартная конфигурация с таймаутом 120 секунд
    static let `default` = NetworkConfiguration(
        timeout: 120
    )

    /// Инициализация конфигурации
    /// - Parameters:
    ///   - timeout: Таймаут для запросов (по умолчанию 120 секунд)
    ///   - session: Пользовательская URLSession (опционально для тестов)
    init(timeout: TimeInterval = 120, session: URLSession? = nil) {
        self.timeout = timeout

        if let session = session {
            self.session = session
        } else {
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = timeout
            config.timeoutIntervalForResource = timeout * 2
            
            // Интеграция Pulse для логирования сетевых запросов
            self.session = URLSession(configuration: config, delegate: URLSessionProxyDelegate(), delegateQueue: nil)
        }

        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
    }
}
