import Foundation

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
    /// - Parameter timeout: Таймаут для запросов (по умолчанию 120 секунд)
    init(timeout: TimeInterval = 120) {
        self.timeout = timeout

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout
        config.timeoutIntervalForResource = timeout * 2

        self.session = URLSession(configuration: config)
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
    }
}
