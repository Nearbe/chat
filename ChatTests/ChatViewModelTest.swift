// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.
import XCTest
import SwiftData
import Combine
@testable import Chat

@MainActor
final class ChatViewModelTests: XCTestCase {
    var container: ModelContainer!
    var viewModel: ChatViewModel!
    var chatServiceMock: ChatServiceMock!
    var networkMonitorMock: NetworkMonitorMock!
    var sessionManager: ChatSessionManager!

    override func setUp() async throws {
        try await super.setUp()
        container = TestHelpers.createInMemoryContainer()
        sessionManager = ChatSessionManager(modelContext: container.mainContext)
        chatServiceMock = ChatServiceMock()
        networkMonitorMock = NetworkMonitorMock()

        viewModel = ChatViewModel()
        viewModel.setup(
            sessionManager: sessionManager,
            chatService: chatServiceMock,
            networkMonitor: networkMonitorMock
        )
    }

    func testLoadModelsSuccess() async {
        let expectedModels = [ModelInfo(id: "model-1", displayName: "Model 1")]
        chatServiceMock.fetchModelsResult = .success(expectedModels)

        await viewModel.loadModels()

        XCTAssertEqual(viewModel.availableModels.count, 1)
        XCTAssertEqual(viewModel.availableModels[0].id, "model-1")
        XCTAssertTrue(viewModel.isServerReachable)
    }

    func testLoadModelsFailure() async {
        chatServiceMock.fetchModelsResult = .failure(NetworkError.networkError(NSError(domain: "", code: -1)))

        await viewModel.loadModels()

        XCTAssertTrue(viewModel.availableModels.isEmpty)
        XCTAssertFalse(viewModel.isServerReachable)
    }

    func testSendMessageCreatesSession() async {
        viewModel.inputText = "Hello"

        await viewModel.sendMessage()

        XCTAssertNotNil(viewModel.currentSession)
        XCTAssertEqual(viewModel.messages.count, 2) // User message + Assistant (placeholder)
        XCTAssertEqual(viewModel.messages[0].content, "Hello")
        XCTAssertEqual(viewModel.messages[1].role, "assistant")
    }

    func testStopGeneration() async {
        viewModel.inputText = "Hello"
        // Setup a stream that doesn't finish immediately
        let (stream, _) = AsyncThrowingStream<ChatCompletionStreamPart, Error>.makeStream()
        chatServiceMock.streamChatResult = stream

        await viewModel.sendMessage()
        XCTAssertTrue(viewModel.isGenerating)

        viewModel.stopGeneration()
        XCTAssertFalse(viewModel.isGenerating)
    }

    func testSetSession() async {
        let session = sessionManager.createSession(modelName: "model-1")
        let message = Message.user(content: "Test", sessionId: session.id, index: 0)
        sessionManager.addMessage(message, to: session)

        viewModel.setSession(session)

        XCTAssertEqual(viewModel.currentSession?.id, session.id)
        XCTAssertEqual(viewModel.messages.count, 1)
        XCTAssertEqual(viewModel.messages[0].content, "Test")
    }

    func testDeleteSession() async {
        let session = sessionManager.createSession(modelName: "model-1")
        viewModel.setSession(session)

        viewModel.deleteSession(session)

        XCTAssertNil(viewModel.currentSession)
        XCTAssertTrue(viewModel.messages.isEmpty)
    }

    func testDeleteMessage() async {
        let session = sessionManager.createSession(modelName: "model-1")
        let message = Message.user(content: "Test", sessionId: session.id, index: 0)
        sessionManager.addMessage(message, to: session)
        viewModel.setSession(session)

        XCTAssertEqual(viewModel.messages.count, 1)

        viewModel.deleteMessage(message)

        XCTAssertTrue(viewModel.messages.isEmpty)
    }

    func testClearError() {
        viewModel.errorMessage = "Some error"
        viewModel.clearError()
        XCTAssertNil(viewModel.errorMessage)
    }

    func testRefreshAuthentication() {
        viewModel.refreshAuthentication()
        XCTAssertFalse(viewModel.isAuthenticated) // По умолчанию на симуляторе без токена
    }

    func testEditMessage() async {
        let session = sessionManager.createSession(modelName: "model-1")
        let message = Message.user(content: "Original", sessionId: session.id, index: 0)
        sessionManager.addMessage(message, to: session)
        viewModel.setSession(session)

        // Mock stream for re-generation
        let (stream, continuation) = AsyncThrowingStream<ChatCompletionStreamPart, Error>.makeStream()
        chatServiceMock.streamChatResult = stream
        continuation.finish()

        await viewModel.editMessage(message, newContent: "Edited")

        XCTAssertEqual(message.content, "Edited")
        XCTAssertEqual(viewModel.messages.count, 2) // Edited user message + new assistant response
    }

    func testCreateNewSession() async {
        let session = viewModel.createNewSession()
        XCTAssertNotNil(viewModel.currentSession)
        XCTAssertEqual(viewModel.currentSession?.id, session.id)
        XCTAssertTrue(viewModel.messages.isEmpty)
    }

    func testCheckServerConnection() async {
        chatServiceMock.fetchModelsResult = .success([])
        await viewModel.checkServerConnection()
        XCTAssertTrue(viewModel.isServerReachable)
    }
}

// Helper for AsyncThrowingStream
extension AsyncThrowingStream where Failure == Error {
    static func makeStream() -> (AsyncThrowingStream<Element, Failure>, Continuation) {
        var continuation: Continuation!
        let stream = AsyncThrowingStream { continuation = $0 }
        return (stream, continuation)
    }
}
