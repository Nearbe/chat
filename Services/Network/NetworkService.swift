// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import Foundation

// MARK: - Сетевой сервис для LM Studio API

/// - Спецификация API: [Docs/LMStudio/developer/rest/index.md](../../Docs/LMStudio/developer/rest/index.md)
/// Основной сервис для взаимодействия с LM Studio REST API.
/// Работает в основном потоке (@MainActor) для безопасного доступа к UI.
///
/// Поддерживаемые операции:
/// - Получение списка моделей
/// - Загрузка/выгрузка моделей в память
/// - Скачивание моделей
/// - Стриминг чата (основная функция)
///
/// Архитектура:
/// - Делегирует HTTP к HTTPClient
/// - Делегирует стриминг к ChatStreamService
/// - Использует DeviceConfiguration для настроек устройства
///
/// - Важно: Все методы async throws для обработки ошибок
/// - Примечание: Использует LM Studio v1 API формат
@MainActor
final class NetworkService {

    // MARK: - Приватные свойства (Private Properties)

    /// HTTP клиент для выполнения запросов
    /// Переиспользуется для всех операций
    private let httpClient: HTTPClient

    /// Сервис для стриминга чата
    /// Использует SSEParser для обработки потока
    private let streamService: ChatStreamService

    /// Ключ токена для текущего устройства
    /// Определяется через DeviceConfiguration
    /// Используется для авторизации в Keychain
    private let tokenKey: String

    // MARK: - Инициализация (Initialization)

    /// Инициализация сетевого сервиса
    /// - Parameters:
    ///   - deviceName: Имя устройства (по умолчанию "Saint Celestine")
    ///   - httpClient: HTTP клиент (по умолчанию создается новый)
    /// Настраивает:
    /// - Ключ токена для устройства
    /// - HTTP клиент
    /// - Сервис стриминга
    init(
        deviceName: String = "Saint Celestine",
        httpClient: HTTPClient = HTTPClient()
    ) {
        // Определяем ключ токена для устройства
        // Используется для поиска токена в Keychain
        self.tokenKey = DeviceConfiguration.configuration(for: DeviceIdentity.currentName)?.tokenKey ?? ""

        self.httpClient = httpClient
        self.streamService = ChatStreamService(httpClient: httpClient)
    }

    // MARK: - API методы (API Methods)

    /// Получить список доступных моделей
    /// - Returns: Массив ModelInfo с информацией о моделях
    /// - Throws: NetworkError при ошибке подключения
    /// - Примечание: Использует эндпоинт /api/v1/models
    func fetchModels() async throws -> [ModelInfo] {
        // Проверяем URL из конфигурации
        guard let url = AppConfig.shared.modelsURL else {
            throw NetworkError.invalidURL
        }

        // Выполняем GET запрос
        let (data, _) = try await httpClient.get(url: url)

        // Декодируем ответ
        let modelsResponse = try httpClient.decode(LMModelsResponse.self, from: data)
        return modelsResponse.models
    }

    /// Загрузить модель в память устройства
    /// - Parameters:
    ///   - model: Путь к модели (id из списка)
    ///   - contextLength: Длина контекста (опционально)
    ///   - flashAttention: Включить Flash Attention (опционально)
    ///   - offloadKVCacheToGPU: Выгрузить KV кэш на GPU (опционально)
    /// - Returns: LMModelLoadResponse с результатом загрузки
    /// - Throws: NetworkError при ошибке
    /// - Примечание: Требует достаточно оперативной памяти
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

        // Создаём запрос с параметрами загрузки
        let loadRequest = LMModelLoadRequest(
            model: model,
            contextLength: contextLength,
            evalBatchSize: nil,
            flashAttention: flashAttention,
            numExperts: nil,
            offloadKVCacheToGPU: offloadKVCacheToGPU,
            echoLoadConfig: true
        )

        // Выполняем POST запрос
        let (data, _) = try await httpClient.post(url: url, body: loadRequest)
        return try httpClient.decode(LMModelLoadResponse.self, from: data)
    }

    /// Выгрузить модель из памяти
    /// - Parameter instanceId: ID загруженного экземпляра модели
    /// - Returns: LMModelUnloadResponse с результатом
    /// - Throws: NetworkError при ошибке
    func unloadModel(instanceId: String) async throws -> LMModelUnloadResponse {
        let baseURL = AppConfig.shared.baseURL
        guard let url = URL(string: "\(baseURL)/api/v1/models/unload") else {
            throw NetworkError.invalidURL
        }

        let unloadRequest = LMModelUnloadRequest(instanceId: instanceId)

        let (data, _) = try await httpClient.post(url: url, body: unloadRequest)
        return try httpClient.decode(LMModelUnloadResponse.self, from: data)
    }

    /// Скачать модель из репозитория
    /// - Parameters:
    ///   - model: Имя модели для скачивания
    ///   - quantization: Уровень квантования (опционально)
    /// - Returns: LMDownloadResponse с информацией о скачивании
    /// - Throws: NetworkError при ошибке
    /// - Примечание: Может занять много времени
    func downloadModel(model: String, quantization: String? = nil) async throws -> LMDownloadResponse {
        let baseURL = AppConfig.shared.baseURL
        guard let url = URL(string: "\(baseURL)/api/v1/models/download") else {
            throw NetworkError.invalidURL
        }

        let downloadRequest = LMDownloadRequest(model: model, quantization: quantization)

        let (data, _) = try await httpClient.post(url: url, body: downloadRequest)
        return try httpClient.decode(LMDownloadResponse.self, from: data)
    }

    /// Получить статус скачивания модели
    /// - Parameter jobId: ID задачи скачивания
    /// - Returns: LMDownloadStatus с текущим состоянием
    /// - Throws: NetworkError при ошибке
    /// - Примечание: Используется для отображения прогресса
    func getDownloadStatus(jobId: String) async throws -> LMDownloadStatus {
        let baseURL = AppConfig.shared.baseURL
        guard let url = URL(string: "\(baseURL)/api/v1/models/download/\(jobId)") else {
            throw NetworkError.invalidURL
        }

        let (data, _) = try await httpClient.get(url: url)
        return try httpClient.decode(LMDownloadStatus.self, from: data)
    }

    /// Стриминг чат-комплишена (основная функция)
    /// - Parameters:
    ///   - messages: Массив сообщений для контекста
    ///   - model: ID модели для генерации
    ///   - temperature: Температура генерации
    ///   - maxTokens: Максимум токенов в ответе
    /// - Returns: AsyncThrowingStream с частями ответа
    /// - Примечание: Основной метод для получения ответов AI
    /// Использует SSE (Server-Sent Events) для стриминга
    func streamChat(
        messages: [ChatMessage],
        model: String,
        temperature: Double?,
        maxTokens: Int?
    ) -> AsyncThrowingStream<ChatCompletionStreamPart, Error> {
        guard let url = AppConfig.shared.chatURL else {
            // Возвращаем стрим с ошибкой если URL некорректен
            return AsyncThrowingStream { continuation in
                continuation.finish(throwing: NetworkError.invalidURL)
            }
        }

        // Делегируем стриминг в ChatStreamService
        return streamService.streamChat(
            url: url,
            messages: messages,
            model: model,
            temperature: temperature,
            maxTokens: maxTokens
        )
    }
}
