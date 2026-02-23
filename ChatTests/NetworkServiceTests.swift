import XCTest
@testable import Chat

@MainActor
final class NetworkServiceTests: XCTestCase {
    var networkService: NetworkService!
    var httpClient: HTTPClient!
    var session: URLSession!

    override func setUp() {
        super.setUp()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolMock.self]
        session = URLSession(configuration: configuration)
        
        let netConfig = NetworkConfiguration(timeout: 5, session: session)
        httpClient = HTTPClient(configuration: netConfig, authProvider: nil)
        networkService = NetworkService(httpClient: httpClient)
    }

    override func tearDown() {
        URLProtocolMock.testResponses = [:]
        URLProtocolMock.requestHandler = nil
        networkService = nil
        httpClient = nil
        session = nil
        super.tearDown()
    }

    func testFetchModelsSuccess() async throws {
        // Given
        let modelsURL = AppConfig.shared.modelsURL!
        let responseJSON = """
        {
          "models": [
            {
              "id": "model-1",
              "object": "model",
              "owned_by": "organization",
              "permission": []
            }
          ]
        }
        """
        let responseData = responseJSON.data(using: .utf8)!
        let response = HTTPURLResponse(url: modelsURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        URLProtocolMock.testResponses[modelsURL] = (responseData, response, nil)

        // When
        let models = try await networkService.fetchModels()

        // Then
        XCTAssertEqual(models.count, 1)
        XCTAssertEqual(models.first?.id, "model-1")
    }

    func testLoadModelSuccess() async throws {
        // Given
        let baseURL = AppConfig.shared.baseURL
        let loadURL = URL(string: "\(baseURL)/api/v1/models/load")!
        let responseJSON = """
        {
          "type": "model_load_response",
          "instance_id": "inst-123",
          "load_time_seconds": 1.5,
          "status": "loaded",
          "model": "test-model"
        }
        """
        let responseData = responseJSON.data(using: .utf8)!
        let response = HTTPURLResponse(url: loadURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        URLProtocolMock.requestHandler = { request in
            XCTAssertEqual(request.url, loadURL)
            XCTAssertEqual(request.httpMethod, "POST")
            return (response, responseData)
        }

        // When
        let result = try await networkService.loadModel(model: "test-model")

        // Then
        XCTAssertEqual(result.instanceId, "inst-123")
    }
}
