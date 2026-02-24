// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.
import Foundation

/// Mock-сервер для имитации ответов LM Studio
/// Используется для тестирования сетевого слоя без реального бэкенда
enum MockLMStudioServer {

    /// Набор предустановленных ответов для различных эндпоинтов
    enum MockResponse {
        case models([String])
        case chatCompletion(String)
        case error(Int)
        case stream([String])
    }

    static func setup(response: MockResponse) {
        URLProtocolMock.requestHandler = { request in
            guard let url = request.url else {
                return (HTTPURLResponse(url: URL(string: "http://localhost")!, statusCode: 400, httpVersion: nil, headerFields: nil)!, nil)
            }

            switch response {
            case .models(let modelIds):
                guard let data = try ? JSONEncoder().encode(["models": modelIds.map {
                    ["key": $0]
                }]) else {
                    return (HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil) !, nil)
                }
                let httpResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: ["Content-Type": "application/json"])!
                return (httpResponse, data)

            case .chatCompletion(let text):
                guard let data = try ? JSONEncoder().encode([
                    "choices": [
                        ["message": ["content": text]]
                    ]
                ]) else {
                    return (HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil) !, nil)
                }
                let httpResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: ["Content-Type": "application/json"])!
                return (httpResponse, data)

            case .error(let code):
                let httpResponse = HTTPURLResponse(url: url, statusCode: code, httpVersion: nil, headerFields: nil)!
                return (httpResponse, nil)

            case .stream(let chunks):
                let fullData = chunks.map {
                    "data: \($0)\n\n"
                }.joined().data(using: .utf8)
                let httpResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: ["Content-Type": "text/event-stream"])!
                return (httpResponse, fullData)
            }
        }
    }
}
