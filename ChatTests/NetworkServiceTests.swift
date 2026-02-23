import XCTest
@testable import Chat

@MainActor
final class NetworkServiceTests: XCTestCase {
    var networkService: NetworkService!
    var httpClient: HTTPClient!
    var session: URLSession!

    override func setUp() async throws {
        try await super.setUp()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolMock.self]
        session = URLSession(configuration: configuration)
        
        let netConfig = NetworkConfiguration(timeout: 5, session: session)
        httpClient = HTTPClient(configuration: netConfig, authProvider: nil)
        networkService = NetworkService(deviceName: "TestDevice", httpClient: httpClient)
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
        let url = AppConfig.shared.modelsURL!
        let json = """
        {
            "data": [
                {
                    "id": "model-1",
                    "object": "model",
                    "owned_by": "organization",
                    "permission": []
                }
            ]
        }
        """
        let responseData = json.data(using: .utf8)!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        URLProtocolMock.testResponses[url] = (responseData, response, nil)

        // When
        let models = try await networkService.fetchModels()

        // Then
        XCTAssertEqual(models.count, 1)
        XCTAssertEqual(models[0].id, "model-1")
    }

    func testLoadModelSuccess() async throws {
        // Given
        let baseURL = AppConfig.shared.baseURL
        let url = URL(string: "\(baseURL)/api/v1/models/load")!
        let json = """
        {
            "instance_id": "inst-1",
            "model": "test-model"
        }
        """
        let responseData = json.data(using: .utf8)!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        URLProtocolMock.requestHandler = { request in
            XCTAssertEqual(request.httpMethod, "POST")
            return (response, responseData)
        }

        // When
        let result = try await networkService.loadModel(model: "test-model")

        // Then
        XCTAssertEqual(result.instanceId, "inst-1")
    }
}
