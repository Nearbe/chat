// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.
import Testing
import SwiftData
import Foundation
@testable import Chat

@MainActor
@Suite(.serialized)
struct ChatSessionManagerTests {
    let container: ModelContainer
    let manager: ChatSessionManager
    
    init() {
        container = TestHelpers.createInMemoryContainer()
        manager = ChatSessionManager(modelContext: container.mainContext)
    }
    
    @Test
    func createSession() {
        // Given/When
        let session = manager.createSession(modelName: "test-model", title: "Test Session")
        
        // Then
        #expect(session.title == "Test Session")
        #expect(session.modelName == "test-model")
    }
    
    @Test
    func addMessage() {
        // Given
        let session = manager.createSession(modelName: "test-model")
        let message = Message.make(role: "user", content: "Hello", sessionId: session.id, index: 0)
        
        // When
        manager.addMessage(message, to: session)
        
        // Then
        #expect(session.messages.count == 1)
        #expect(session.messages[0].content == "Hello")
        #expect(session.title == "Hello") // Заголовок должен обновиться автоматически
    }
    
    @Test
    func deleteSession() {
        // Given
        let session = manager.createSession(modelName: "test-model")
        let sessionId = session.id
        
        // When
        manager.deleteSession(session)
        
        // Then
        // Проверяем, что сессия удалена из контекста
        let descriptor = FetchDescriptor<ChatSession>(predicate: #Predicate { $0.id == sessionId })
        let count = try? container.mainContext.fetchCount(descriptor)
        #expect(count == 0)
    }
    
    @Test
    func deleteMessagesAfterIndex() {
        // Given
        let session = manager.createSession(modelName: "test-model")
        
        let messages = (0...3).map { i in
            Message.make(role: i % 2 == 0 ? "user" : "assistant", content: "\(i)", sessionId: session.id, index: i)
        }
        
        messages.forEach { manager.addMessage($0, to: session) }
        #expect(session.messages.count == 4)
        
        // When
        manager.deleteMessages(after: 1, in: session)
        
        // Then
        #expect(session.messages.count == 2)
        #expect(session.messages.contains(where: { $0.index == 0 }))
        #expect(session.messages.contains(where: { $0.index == 1 }))
        #expect(!session.messages.contains(where: { $0.index == 2 }))
    }
}
