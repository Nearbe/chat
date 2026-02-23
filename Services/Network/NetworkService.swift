import Foundation

/// Сетевой сервис для работы с LM Studio API
@MainActor
final class NetworkService {
    private let httpClient: HTTPClient
    private let streamService: ChatStreamService
    private let tokenKey: String

    init(deviceName: String = "Saint Celestine") {
        // Определяем ключ токена для устройства
        self.tokenKey = DeviceConfiguration.configuration(for: DeviceIdentity.currentName)?.tokenKey ?? ""
        
        self.httpClient = HTTPClient()
        self.streamService = ChatStreamService(httpClient: httpClient)
    }

    // MARK: - API Methods

    /// Получить список доступных моделей
    func fetchModels() async throws -> [ModelInfo] {
        guard let url = AppConfig.shared.modelsURL else {
            throw NetworkError.invalidURL
        }

        let (data, _) = try await httpClient.get(url: url)
        let modelsResponse = try httpClient.decode(LMModelsResponse.self, from: data)
        return modelsResponse.models
    }

    /// Загрузить модель в память
    func loadModel(
        model: String,
        contextLength: Int? = nil,
        flashAttention: Bool? = nil,
        offloadKVCacheToGPU: Bool? = nil
    ) async throws -> LMModelLoadResponse {
        let baseURL = AppConfig.shared.baseURL
        guard let url = URL(string: "\(baseURL)/api/v1/models/load") else {
            throw NetworkError.invalidURL
        }

        let loadRequest = LMModelLoadRequest(
            model: model,
            contextLength: contextLength,
            evalBatchSize: nil,
            flashAttention: flashAttention,
            numExperts: nil,
            offloadKVCacheToGPU: offloadKVCacheToGPU,
            echoLoadConfig: true
        )

        let (data, _) = try await httpClient.post(url: url, body: loadRequest)
        return try httpClient.decode(LMModelLoadResponse.self, from: data)
    }

    /// Выгрузить модель из памяти
    func unloadModel(instanceId: String) async throws -> LMModelUnloadResponse {
        let baseURL = AppConfig.shared.baseURL
        guard let url = URL(string: "\(baseURL)/api/v1/models/unload") else {
            throw NetworkError.invalidURL
        }

        let unloadRequest = LMModelUnloadRequest(instanceId: instanceId)

        let (data, _) = try await httpClient.post(url: url, body: unloadRequest)
        return try httpClient.decode(LMModelUnloadResponse.self, from: data)
    }

    /// Скачать модель
    func downloadModel(model: String, quantization: String? = nil) async throws -> LMDownloadResponse {
        let baseURL = AppConfig.shared.baseURL
        guard let url = URL(string: "\(baseURL)/api/v1/models/download") else {
            throw NetworkError.invalidURL
        }

        let downloadRequest = LMDownloadRequest(model: model, quantization: quantization)

        let (data, _) = try await httpClient.post(url: url, body: downloadRequest)
        return try httpClient.decode(LMDownloadResponse.self, from: data)
    }

    /// Получить статус скачивания
    func getDownloadStatus(jobId: String) async throws -> LMDownloadStatus {
        let baseURL = AppConfig.shared.baseURL
        guard let url = URL(string: "\(baseURL)/api/v1/models/download/\(jobId)") else {
            throw NetworkError.invalidURL
        }

        let (data, _) = try await httpClient.get(url: url)
        return try httpClient.decode(LMDownloadStatus.self, from: data)
    }

    /// Streaming chat completion
    func streamChat(messages: [ChatMessage], model: String, temperature: Double?, maxTokens: Int?) -> AsyncThrowingStream<ChatCompletionStreamPart, Error> {
        guard let url = AppConfig.shared.chatURL else {
            return AsyncThrowingStream { continuation in
                continuation.finish(throwing: NetworkError.invalidURL)
            }
        }

        return streamService.streamChat(url: url, messages: messages, model: model, temperature: temperature, maxTokens: maxTokens)
    }
}
