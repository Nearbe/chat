import Foundation

/// HTTP клиент для выполнения запросов
final class HTTPClient: @unchecked Sendable {
    private let configuration: NetworkConfiguration

    init(configuration: NetworkConfiguration = .default) {
        self.configuration = configuration
    }

    /// GET запрос
    func get(url: URL) async throws -> (Data, URLResponse) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        addAuthHeader(to: &request)

        let (data, response) = try await configuration.session.data(for: request)
        try handleResponse(response)
        return (data, response)
    }

    /// POST запрос с JSON телом
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

    /// POST запрос с байтовым стримом
    func postStreaming<T: Encodable>(url: URL, body: T, accept: String = "text/event-stream") async throws -> (URLSession.AsyncBytes, URLResponse) {
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

    /// Декодировать JSON
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        try configuration.decoder.decode(type, from: data)
    }

    // MARK: - Private

    private func addAuthHeader(to request: inout URLRequest) {
        // Читаем токен из Keychain по ключу устройства
        guard let config = DeviceConfiguration.configuration(for: DeviceIdentity.currentName),
              let token = KeychainHelper.get(key: config.tokenKey),
              !token.isEmpty else {
            return
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }

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
