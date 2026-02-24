// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.

import Foundation
import Testing
@testable import Chat

@MainActor
@Suite(.serialized)
struct HTTPClientTests {
    let httpClient: HTTPClient
    let session: URLSession

    init() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolMock.self]
        session = URLSession(configuration: configuration)

        let netConfig = NetworkConfiguration(timeout: 5, session: session)
        httpClient = HTTPClient(configuration: netConfig, authProvider: nil)

        // Reset mock state
        URLProtocolMock.testResponses = [:]
        URLProtocolMock.requestHandler = nil
    }

    @Test
    /// Тест успешного GET запроса.
    func getRequestSuccess() async throws {
        // Given
        let url = URL(string: "https://api.example.com/test")!
        let responseData = Data("{\"status\": \"ok\"}".utf8)
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!

        URLProtocolMock.testResponses[url] = TestResponse(data: responseData, response: response, error: nil)

        // When
        let (data, _) = try await httpClient.get(url: url)

        // Then
        #expect(data == responseData)
    }

    @Test
    /// Тест успешного POST запроса.
    func postRequestSuccess() async throws {
        // Given
        let url = URL(string: "https://api.example.com/post")!
        let body = ["key": "value"]
        let responseData = Data("{\"result\": \"success\"}".utf8)
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!

        URLProtocolMock.requestHandler = { request in
            #expect(request.httpMethod == "POST")
            #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
            return (response, responseData)
        }

        // When
        let (data, _) = try await httpClient.post(url: url, body: body)

        // Then
        #expect(data == responseData)
    }

    @Test(arguments: [
        (401, NetworkError.unauthorized),
        (429, NetworkError.rateLimited(retryAfter: 60))
    ])
    /// Вспомогательный метод для обработки ошибок HTTP.
    func handleErrors(statusCode: Int, expectedError: NetworkError) async {
        // Given
        let url = URL(string: "https://api.example.com/error")!
        let headerFields = statusCode == 429 ? ["Retry-After": "60"] : nil
        let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: headerFields)!
        URLProtocolMock.testResponses[url] = TestResponse(data: Data(), response: response, error: nil)

        // When/Then
        await #expect(throws: NetworkError.self) {
            try await httpClient.get(url: url)
        }
    }
}
