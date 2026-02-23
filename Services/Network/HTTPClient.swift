// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import Foundation

/// - Документация: [Docs/Pulse/README.md](../../Docs/Pulse/README.md)
/// HTTP клиент для выполнения сетевых запросов.
/// Инкапсулирует логику работы с URLSession, обработку заголовков авторизации и ошибок.
final class HTTPClient: @unchecked Sendable {
    /// Конфигурация сети (сессия, энкодеры/декодеры)
    private let configuration: NetworkConfiguration

    /// Провайдер авторизации
    private let authProvider: AuthorizationProvider?

    /// Инициализация клиента
    /// - Parameters:
    ///   - configuration: Настройки сети (по умолчанию используются стандартные)
    ///   - authProvider: Провайдер авторизации (опционально)
    init(
        configuration: NetworkConfiguration = .default,
        authProvider: AuthorizationProvider? = DeviceAuthorizationProvider()
    ) {
        self.configuration = configuration
        self.authProvider = authProvider
    }

    /// Выполнение GET запроса
    /// - Parameter url: URL адрес запроса
    /// - Returns: Кортеж из полученных данных и ответа сервера
    /// - Throws: Ошибки сети или некорректные статус-коды
    func get(url: URL) async throws -> (Data, URLResponse) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        addAuthHeader(to: &request)

        let (data, response) = try await configuration.session.data(for: request)
        try handleResponse(response)
        return (data, response)
    }

    /// Выполнение POST запроса с JSON телом
    /// - Parameters:
    ///   - url: URL адрес запроса
    ///   - body: Объект для кодирования в JSON
    /// - Returns: Кортеж из полученных данных и ответа сервера
    /// - Throws: Ошибки кодирования, сети или некорректные статус-коды
    func post<T: Encodable>(url: URL, body: T) async throws -> (Data, URLResponse) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        addAuthHeader(to: &request)
        request.httpBody = try configuration.encoder.encode(body)

        let (data, response) = try await configuration.session.data(for: request)
        try handleResponse(response)
        return (data, response)
    }

    /// Выполнение POST запроса с поддержкой стриминга данных (SSE)
    /// - Parameters:
    ///   - url: URL адрес запроса
    ///   - body: Объект для кодирования в JSON
    ///   - accept: Тип принимаемого контента (по умолчанию text/event-stream)
    /// - Returns: Кортеж из асинхронного потока байт и ответа сервера
    /// - Throws: Ошибки сети или некорректные статус-коды
    func postStreaming<T: Encodable>(
        url: URL,
        body: T,
        accept: String = "text/event-stream"
    ) async throws -> (URLSession.AsyncBytes, URLResponse) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(accept, forHTTPHeaderField: "Accept")
        addAuthHeader(to: &request)
        request.httpBody = try configuration.encoder.encode(body)

        let (bytes, response) = try await configuration.session.bytes(for: request)
        try handleResponse(response)
        return (bytes, response)
    }

    /// Декодирование JSON данных в модель
    /// - Parameters:
    ///   - type: Тип результирующей модели
    ///   - data: Данные для декодирования
    /// - Returns: Декодированный объект
    /// - Throws: DecodingError если структура данных не совпадает
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        try configuration.decoder.decode(type, from: data)
    }

    // MARK: - Private (Приватные методы)

    /// Добавление заголовка Authorization (Bearer токен) к запросу
    /// Токен берется из провайдера авторизации
    private func addAuthHeader(to request: inout URLRequest) {
        if let authHeader = authProvider?.authorizationHeader() {
            request.setValue(authHeader, forHTTPHeaderField: "Authorization")
        }
    }

    /// Валидация HTTP ответа по статус-коду
    /// - Parameter response: Ответ сервера
    /// - Throws: NetworkError при получении статус-кода ошибки
    private func handleResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown
        }

        switch httpResponse.statusCode {
        case 200...299:
            return
        case 400:
            throw NetworkError.serverError(400, "Неверный запрос")
        case 401:
            throw NetworkError.unauthorized
        case 403:
            throw NetworkError.forbidden
        case 429:
            let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After").flatMap { Int($0) }
            throw NetworkError.rateLimited(retryAfter: retryAfter)
        case 500...503:
            throw NetworkError.serverError(httpResponse.statusCode, "Сервер недоступен")
        default:
            throw NetworkError.serverError(httpResponse.statusCode, nil)
        }
    }
}
