// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.
import Foundation

/// Mock-сервер для имитации ответов LM Studio
/// Используется для тестирования сетевого слоя без реального бэкенда
class MockLMStudioServer {
    
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
                let data = try! JSONEncoder().encode(["models": modelIds.map { ["key": $0] }])
                let httpResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: ["Content-Type": "application/json"])!
                return (httpResponse, data)
                
            case .chatCompletion(let text):
                let data = try! JSONEncoder().encode([
                    "choices": [
                        ["message": ["content": text]]
                    ]
                ])
                let httpResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: ["Content-Type": "application/json"])!
                return (httpResponse, data)
                
            case .error(let code):
                let httpResponse = HTTPURLResponse(url: url, statusCode: code, httpVersion: nil, headerFields: nil)!
                return (httpResponse, nil)
                
            case .stream(let chunks):
                // Для стриминга возвращаем пустую дату здесь, а саму логику чанков нужно будет обрабатывать иначе,
                // но для базовых тестов мок-протокола достаточно вернуть комбинированный ответ или ошибку.
                // В текущей реализации URLProtocolMock не поддерживает настоящую потоковую передачу чанками через callback,
                // он отдает всё сразу. Для тестов SSE этого может быть достаточно, если склеить чанки.
                let fullData = chunks.map { "data: \($0)\n\n" }.joined().data(using: .utf8)!
                let httpResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: ["Content-Type": "text/event-stream"])!
                return (httpResponse, fullData)
            }
        }
    }
}
