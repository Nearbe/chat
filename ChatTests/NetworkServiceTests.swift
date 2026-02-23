import Testing
import Foundation
@testable import Chat

@MainActor
struct NetworkServiceTests {
    let networkService: NetworkService
    let httpClient: HTTPClient
    let session: URLSession

    init() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolMock.self]
        session = URLSession(configuration: configuration)
        
        let netConfig = NetworkConfiguration(timeout: 5, session: session)
        httpClient = HTTPClient(configuration: netConfig, authProvider: nil)
        networkService = NetworkService(httpClient: httpClient)
        
        // Reset mock state
        URLProtocolMock.testResponses = [:]
        URLProtocolMock.requestHandler = nil
    }

    @Test
    func fetchModelsSuccess() async throws {
        // Given
        let modelsURL = AppConfig.shared.modelsURL!
        let responseJSON = """
        {
          "models": [
            {
              "key": "model-1",
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
        #expect(models.count == 1)
        #expect(models.first?.id == "model-1")
    }

    @Test
    func loadModelSuccess() async throws {
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
            #expect(request.url == loadURL)
            #expect(request.httpMethod == "POST")
            return (response, responseData)
        }

        // When
        let result = try await networkService.loadModel(model: "test-model")

        // Then
        #expect(result.instanceId == "inst-123")
    }

    @Test
    func unloadModelSuccess() async throws {
        // Given
        let baseURL = AppConfig.shared.baseURL
        let unloadURL = URL(string: "\(baseURL)/api/v1/models/unload")!
        let responseJSON = """
        {
          "type": "model_unload_response",
          "instance_id": "inst-123",
          "status": "unloaded"
        }
        """
        let responseData = responseJSON.data(using: .utf8)!
        let response = HTTPURLResponse(url: unloadURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        URLProtocolMock.requestHandler = { request in
            #expect(request.url == unloadURL)
            #expect(request.httpMethod == "POST")
            return (response, responseData)
        }

        // When
        let result = try await networkService.unloadModel(instanceId: "inst-123")

        // Then
        #expect(result.instanceId == "inst-123")
    }

    @Test
    func downloadModelSuccess() async throws {
        // Given
        let baseURL = AppConfig.shared.baseURL
        let downloadURL = URL(string: "\(baseURL)/api/v1/models/download")!
        let responseJSON = """
        {
          "type": "model_download_response",
          "job_id": "job-456",
          "status": "started"
        }
        """
        let responseData = responseJSON.data(using: .utf8)!
        let response = HTTPURLResponse(url: downloadURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        URLProtocolMock.requestHandler = { request in
            #expect(request.url == downloadURL)
            #expect(request.httpMethod == "POST")
            return (response, responseData)
        }

        // When
        let result = try await networkService.downloadModel(model: "test-model")

        // Then
        #expect(result.jobId == "job-456")
    }

    @Test
    func getDownloadStatusSuccess() async throws {
        // Given
        let baseURL = AppConfig.shared.baseURL
        let jobURL = URL(string: "\(baseURL)/api/v1/models/download/job-456")!
        let responseJSON = """
        {
          "type": "model_download_status",
          "job_id": "job-456",
          "status": "downloading",
          "progress": 0.5
        }
        """
        let responseData = responseJSON.data(using: .utf8)!
        let response = HTTPURLResponse(url: jobURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        URLProtocolMock.requestHandler = { request in
            #expect(request.url == jobURL)
            #expect(request.httpMethod == "GET")
            return (response, responseData)
        }

        // When
        let result = try await networkService.getDownloadStatus(jobId: "job-456")

        // Then
        #expect(result.jobId == "job-456")
        #expect(result.status == "downloading")
    }
}
