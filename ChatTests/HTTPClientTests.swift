import XCTest
@testable import Chat

@MainActor
final class HTTPClientTests: XCTestCase {
    var httpClient: HTTPClient!
    var session: URLSession!

    override func setUp() {
        super.setUp()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolMock.self]
        session = URLSession(configuration: configuration)
        
        let netConfig = NetworkConfiguration(timeout: 5, session: session)
        httpClient = HTTPClient(configuration: netConfig, authProvider: nil)
    }

    override func tearDown() {
        URLProtocolMock.testResponses = [:]
        URLProtocolMock.requestHandler = nil
        httpClient = nil
        session = nil
        super.tearDown()
    }

    func testGetRequestSuccess() async throws {
        // Given
        let url = URL(string: "https://api.example.com/test")!
        let responseData = "{\"status\": \"ok\"}".data(using: .utf8)!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        URLProtocolMock.testResponses[url] = (responseData, response, nil)

        // When
        let (data, _) = try await httpClient.get(url: url)

        // Then
        XCTAssertEqual(data, responseData)
    }

    func testPostRequestSuccess() async throws {
        // Given
        let url = URL(string: "https://api.example.com/post")!
        let body = ["key": "value"]
        let responseData = "{\"result\": \"success\"}".data(using: .utf8)!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        URLProtocolMock.requestHandler = { request in
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
            return (response, responseData)
        }

        // When
        let (data, _) = try await httpClient.post(url: url, body: body)

        // Then
        XCTAssertEqual(data, responseData)
    }

    func testHandleUnauthorizedError() async {
        // Given
        let url = URL(string: "https://api.example.com/secure")!
        let response = HTTPURLResponse(url: url, statusCode: 401, httpVersion: nil, headerFields: nil)!
        URLProtocolMock.testResponses[url] = (Data(), response, nil)

        // When/Then
        do {
            _ = try await httpClient.get(url: url)
            XCTFail("Should throw unauthorized error")
        } catch let error as NetworkError {
            if case .unauthorized = error {
                // Success
            } else {
                XCTFail("Wrong error type: \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testHandleRateLimitError() async {
        // Given
        let url = URL(string: "https://api.example.com/limited")!
        let response = HTTPURLResponse(url: url, statusCode: 429, httpVersion: nil, headerFields: ["Retry-After": "60"])!
        URLProtocolMock.testResponses[url] = (Data(), response, nil)

        // When/Then
        do {
            _ = try await httpClient.get(url: url)
            XCTFail("Should throw rateLimited error")
        } catch let error as NetworkError {
            if case .rateLimited(let retryAfter) = error {
                XCTAssertEqual(retryAfter, 60)
            } else {
                XCTFail("Wrong error type: \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
