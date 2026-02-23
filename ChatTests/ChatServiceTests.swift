// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.
import Testing
import Combine
import Foundation
@testable import Chat

@MainActor
struct ChatServiceTests {
    let chatService: ChatService
    let session: URLSession
    
    init() {
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
        
        // Reset mock state
        URLProtocolMock.testResponses = [:]
        URLProtocolMock.requestHandler = nil
    }
    
    @Test
    /// Тест запроса списка моделей.
    func fetchModelsRequest() async throws {
        guard let url = AppConfig.shared.modelsURL else {
            Issue.record("Models URL is nil in AppConfig")
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
            #expect(request.url == url)
            #expect(request.httpMethod == "GET")
            return (response, responseData)
        }
        
        let models = try await chatService.fetchModels()
        
        #expect(models.count == 1)
        #expect(models[0].id == "model-1")
    }
    
    @Test
    /// Тест обработки ошибки при получении моделей.
    func fetchModelsError() async {
        MockLMStudioServer.setup(response: .error(500))
        
        do {
            _ = try await chatService.fetchModels()
            Issue.record("Should throw error")
        } catch {
            // Success
        }
    }
    
    @Test
    /// Тест успешного получения моделей через Mock сервер.
    func fetchModelsSuccessWithMockServer() async throws {
        let expectedModels = ["gpt-4", "claude-3"]
        MockLMStudioServer.setup(response: .models(expectedModels))
        
        let models = try await chatService.fetchModels()
        
        #expect(models.count == 2)
        #expect(models[0].id == "gpt-4")
        #expect(models[1].id == "claude-3")
    }
}
