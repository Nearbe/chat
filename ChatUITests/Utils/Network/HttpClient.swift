// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.

import Foundation

/// HTTP клиент для отправки запросов к локальному Python серверу
@MainActor
final class UTHttpClient {

    // MARK: - Публичные методы

    /// Настроить HTTP запрос
    /// - Parameters:
    ///   - url: URL для запроса
    ///   - method: HTTP метод (GET, POST и т.д.)
    ///   - parameters: Параметры запроса
    ///   - body: Тело запроса
    ///   - headers: Заголовки запроса
    /// - Returns: Настроенный URLRequest
    func setup(
        request url: URL,
        method: String,
        parameters: [String: String]? = nil,
        body: Data? = nil,
        headers: [String: String]? = nil
    ) -> URLRequest {
        Logger.info("----------Setup Request----------")
        Logger.info("URL: \(url.absoluteURL)")

        var request = URLRequest(url: url)
        request.httpMethod = method
        Logger.info("Method: \(method)")

        if let parameters = parameters {
            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
            Logger.info("Parameters: \(parameters)")
        } else if let body = body {
            request.httpBody = body
            Logger.info("Body: \(String(decoding: body, as: UTF8.self))")
        }

        if let headers = headers {
            Logger.info("Headers: \(headers)")
            headers.forEach { key, value in
                request.addValue(value, forHTTPHeaderField: key)
            }
        }

        Logger.info("----------Setup End----------\n")

        return request
    }

    /// Отправить HTTP запрос
    /// - Parameters:
    ///   - request: URLRequest для отправки
    ///   - onCompletion: Колбэк по завершении
    func send(
        request: URLRequest,
        onCompletion: @escaping (_: Error?, _: Data?) -> Void
    ) {
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            Logger.info("----------Send Request----------")
            onCompletion(error, data)
            Logger.info("----------End----------\n")
        }
        task.resume()
    }

    /// Отправить HTTP запрос с телом
    /// - Parameters:
    ///   - request: URLRequest для отправки
    ///   - body: Тело запроса
    ///   - onCompletion: Колбэк по завершении
    func send(
        request: URLRequest,
        body: Data,
        onCompletion: @escaping (_: Error?, _: Data?) -> Void
    ) {
        let task = URLSession.shared.uploadTask(with: request, from: body) { data, _, error in
            Logger.info("----------Send Request----------")
            onCompletion(error, data)
            Logger.info("----------End----------\n")
        }
        task.resume()
    }
}
