import Foundation
import UIKit
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
                return "Превышен лимит. Повторите через \(seconds) сек."
            }
            return "Превышен лимит запросов"
        case .networkError(let error):
            return "Ошибка сети: \(error.localizedDescription)"
        case .unknown:
            return "Неизвестная ошибка"
        }
    }
}

/// Actor для потокобезопасных сетевых запросов
actor NetworkService {
    private let session: URLSession
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let deviceName: String

    init(deviceName: String = "Saint Celestine") {
        self.deviceName = deviceName
        let config = URLSessionConfiguration.default
        let timeout: TimeInterval = 120
        config.timeoutIntervalForRequest = timeout
        config.timeoutIntervalForResource = timeout * 2
        self.session = URLSession(configuration: config)
    }

    private var authToken: String? {
        let keychainKey = deviceName == "Saint Celestine" ? "auth_token_nearbe" : "auth_token_kotya"
        return KeychainHelper.get(key: keychainKey)
    }

    /// Получить список доступных моделей
    func fetchModels() async throws -> [ModelInfo] {
        guard let url = await AppConfig.shared.modelsURL else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        addAuthHeader(to: &request)

        let (data, response) = try await session.data(for: request)
        try handleResponse(response)

        let modelsResponse = try decoder.decode(ModelsResponse.self, from: data)
        return modelsResponse.data
    }

    /// Streaming chat completion
    func streamChat(request: ChatCompletionRequest) -> AsyncThrowingStream<ChatCompletionStreamPart, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    try Task.checkCancellation()

                    guard let url = await AppConfig.shared.chatURL else {
                        throw NetworkError.invalidURL
                    }

                    var urlRequest = URLRequest(url: url)
                    urlRequest.httpMethod = "POST"
                    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    urlRequest.setValue("text/event-stream", forHTTPHeaderField: "Accept")
                    urlRequest.setValue("chunked", forHTTPHeaderField: "Transfer-Encoding")
                    addAuthHeader(to: &urlRequest)

                    urlRequest.httpBody = try encoder.encode(request)

                    let (bytes, response) = try await session.bytes(for: urlRequest)
                    try handleResponse(response)

                    var buffer = ""

                    for try await byte in bytes {
                        try Task.checkCancellation()

                        let char = Character(UnicodeScalar(byte))
                        buffer.append(char)

                        if char == "\n" {
                            if let line = buffer.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
                               line.hasPrefix("data: ") {
                                let jsonString = String(line.dropFirst(6))
                                if jsonString == "[DONE]" {
                                    continuation.finish()
                                    return
                                }

                                if let data = jsonString.data(using: .utf8) {
                                    do {
                                        let chunk = try decoder.decode(ChatCompletionStreamPart.self, from: data)
                                        continuation.yield(chunk)
                                    } catch {
                                        // Логируем ошибку декодирования, но продолжаем
                                        print("[NetworkService] Decode error: \(error.localizedDescription)")
                                    }
                                }
                            }
                            buffer = ""
                        }
                    }

                    continuation.finish()
                } catch is CancellationError {
                    continuation.finish(throwing: CancellationError())
                } catch {
                    continuation.finish(throwing: error)
                }
            }

            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }

    /// Добавить заголовок авторизации
    private func addAuthHeader(to request: inout URLRequest) {
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }

    /// Обработать HTTP-ответ
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
