// MARK: - Связь с документацией: LM Studio (Версия: main). Статус: Синхронизировано.
import Foundation

/// Протокол для сервиса чата
@MainActor
protocol ChatServiceProtocol: AnyObject {
    /// Получить список доступных моделей
    func fetchModels() async throws -> [ModelInfo]
    
    /// Начать поток генерации ответа от AI
    func streamChat(
        messages: [ChatMessage],
        model: String,
        temperature: Double?,
        maxTokens: Int?
    ) -> AsyncThrowingStream<ChatCompletionStreamPart, Error>
}

/// Сервис для управления бизнес-логикой чата
@MainActor
final class ChatService: ObservableObject, ChatServiceProtocol {
    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    /// Загрузить список доступных моделей от сервера
    /// - Returns: Список объектов `ModelInfo`
    /// - Throws: `NetworkError` при проблемах с сетью
    func fetchModels() async throws -> [ModelInfo] {
        try await networkService.fetchModels()
    }
    
    /// Начать поток генерации ответа от AI
    /// - Parameters:
    ///   - messages: История сообщений в формате API
    ///   - model: Идентификатор выбранной модели
    ///   - temperature: Параметр случайности (0.0 - 2.0)
    ///   - maxTokens: Лимит токенов генерации
    /// - Returns: `AsyncThrowingStream` с частями ответа (`ChatCompletionStreamPart`)
    func streamChat(
        messages: [ChatMessage],
        model: String,
        temperature: Double?,
        maxTokens: Int?
    ) -> AsyncThrowingStream<ChatCompletionStreamPart, Error> {
        networkService.streamChat(
            messages: messages,
            model: model,
            temperature: temperature,
            maxTokens: maxTokens
        )
    }
}
