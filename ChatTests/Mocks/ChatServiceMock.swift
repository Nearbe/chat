import Foundation
import Combine
@testable import Chat

@MainActor
final class ChatServiceMock: ChatServiceProtocol {
    var fetchModelsResult: Result<[ModelInfo], Error> = .success([])
    var streamChatResult: AsyncThrowingStream<ChatCompletionStreamPart, Error>?
    
    var fetchModelsCalled = false
    var streamChatCalled = false

    func fetchModels() async throws -> [ModelInfo] {
        fetchModelsCalled = true
        switch fetchModelsResult {
        case .success(let models):
            return models
        case .failure(let error):
            throw error
        }
    }

    func streamChat(
        messages: [ChatMessage],
        model: String,
        temperature: Double?,
        maxTokens: Int?
    ) -> AsyncThrowingStream<ChatCompletionStreamPart, Error> {
        streamChatCalled = true
        if let stream = streamChatResult {
            return stream
        }
        return AsyncThrowingStream { $0.finish() }
    }
}
