import XCTest
import SwiftData
@testable import Chat

@MainActor
final class ChatSessionManagerTests: XCTestCase {
    var container: ModelContainer!
    var manager: ChatSessionManager!
    
    override func setUp() {
        super.setUp()
        container = TestHelpers.createInMemoryContainer()
        manager = ChatSessionManager(modelContext: container.mainContext)
    }
    
    func testCreateSession() {
        let session = manager.createSession(modelName: "test-model", title: "Test Session")
        
        XCTAssertEqual(session.title, "Test Session")
        XCTAssertEqual(session.modelName, "test-model")
        XCTAssertNotNil(session.id)
    }
    
    func testAddMessage() {
        let session = manager.createSession(modelName: "test-model")
        let message = Message.user(content: "Hello", sessionId: session.id, index: 0)
        
        manager.addMessage(message, to: session)
        
        XCTAssertEqual(session.messages.count, 1)
        XCTAssertEqual(session.messages[0].content, "Hello")
        XCTAssertEqual(session.title, "Hello") // Title should update automatically
    }
    
    func testDeleteSession() {
        let session = manager.createSession(modelName: "test-model")
        let sessionId = session.id
        
        manager.deleteSession(session)
        
        // Verify it's gone from context
        let descriptor = FetchDescriptor<ChatSession>(predicate: #Predicate { $0.id == sessionId })
        let count = try? container.mainContext.fetchCount(descriptor)
        XCTAssertEqual(count, 0)
    }
    
    func testDeleteMessagesAfterIndex() {
        let session = manager.createSession(modelName: "test-model")
        
        let m0 = Message.user(content: "0", sessionId: session.id, index: 0)
        let m1 = Message.assistant(content: "1", sessionId: session.id, index: 1)
        let m2 = Message.user(content: "2", sessionId: session.id, index: 2)
        let m3 = Message.assistant(content: "3", sessionId: session.id, index: 3)
        
        manager.addMessage(m0, to: session)
        manager.addMessage(m1, to: session)
        manager.addMessage(m2, to: session)
        manager.addMessage(m3, to: session)
        
        XCTAssertEqual(session.messages.count, 4)
        
        manager.deleteMessages(after: 1, in: session)
        
        XCTAssertEqual(session.messages.count, 2)
        XCTAssertTrue(session.messages.contains(where: { $0.index == 0 }))
        XCTAssertTrue(session.messages.contains(where: { $0.index == 1 }))
        XCTAssertFalse(session.messages.contains(where: { $0.index == 2 }))
    }
}
