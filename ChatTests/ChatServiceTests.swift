import XCTest
import Combine
@testable import Chat

@MainActor
final class ChatServiceTests: XCTestCase {
    var chatService: ChatService!
    var session: URLSession!
    
    override func setUp() {
        super.setUp()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolMock.self]
        session = URLSession(configuration: configuration)
        
        // Создаем HTTPClient с тестовой конфигурацией
        let netConfig = NetworkConfiguration(timeout: 5, session: session)
        let httpClient = HTTPClient(configuration: netConfig)
        
        // В NetworkService.init используется DeviceConfiguration для tokenKey.
        // В тестах DeviceIdentity.currentName может не существовать в списке.
        let networkService = NetworkService(httpClient: httpClient)
        chatService = ChatService(networkService: networkService)
    }
    
    override func tearDown() {
        URLProtocolMock.testResponses = [:]
        URLProtocolMock.requestHandler = nil
        super.tearDown()
    }
    
    func testFetchModelsRequest() async throws {
        guard let url = AppConfig.shared.modelsURL else {
            XCTFail("Models URL is nil in AppConfig")
            return
        }
        
        let responseData = """
        {
            "models": [
                { "key": "model-1", "display_name": "Model 1" }
            ]
        }
        """.data(using: .utf8)!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        URLProtocolMock.requestHandler = { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            return (response, responseData)
        }
        
        let models = try await chatService.fetchModels()
        
        XCTAssertEqual(models.count, 1)
        XCTAssertEqual(models[0].id, "model-1")
    }
    
    func testFetchModelsError() async {
        MockLMStudioServer.setup(response: .error(500))
        
        do {
            _ = try await chatService.fetchModels()
            XCTFail("Should throw error")
        } catch {
            // Success
        }
    }
    
    func testFetchModelsSuccessWithMockServer() async throws {
        let expectedModels = ["gpt-4", "claude-3"]
        MockLMStudioServer.setup(response: .models(expectedModels))
        
        let models = try await chatService.fetchModels()
        
        XCTAssertEqual(models.count, 2)
        XCTAssertEqual(models[0].id, "gpt-4")
        XCTAssertEqual(models[1].id, "claude-3")
    }
}
