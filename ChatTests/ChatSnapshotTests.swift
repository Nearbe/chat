import XCTest
import SwiftUI
import SnapshotTesting
@testable import Chat

@MainActor
final class ChatSnapshotTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // isRecording = true // Раскомментируйте, чтобы обновить снапшоты
    }
    
    func testChatViewDefault() {
        let container = TestHelpers.createInMemoryContainer()
        let sessionManager = ChatSessionManager(modelContext: container.mainContext)
        let networkService = NetworkService()
        let chatService = ChatService(networkService: networkService)
        
        let view = ChatView()
            .environmentObject(sessionManager)
            .environmentObject(chatService)
            .environmentObject(NetworkMonitor())
        
        let vc = UIHostingController(rootView: view)
        
        assertSnapshot(matching: vc, as: .image(on: .iPhone13ProMax))
    }
    
    func testChatViewDarkMode() {
        let container = TestHelpers.createInMemoryContainer()
        let sessionManager = ChatSessionManager(modelContext: container.mainContext)
        let networkService = NetworkService()
        let chatService = ChatService(networkService: networkService)
        
        let view = ChatView()
            .environmentObject(sessionManager)
            .environmentObject(chatService)
            .environmentObject(NetworkMonitor())
            .preferredColorScheme(.dark)
        
        let vc = UIHostingController(rootView: view)
        
        assertSnapshot(matching: vc, as: .image(on: .iPhone13ProMax))
    }
    
    func testChatViewWithDynamicType() {
        let container = TestHelpers.createInMemoryContainer()
        let sessionManager = ChatSessionManager(modelContext: container.mainContext)
        let networkService = NetworkService()
        let chatService = ChatService(networkService: networkService)
        
        let view = ChatView()
            .environmentObject(sessionManager)
            .environmentObject(chatService)
            .environmentObject(NetworkMonitor())
            .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
        
        let vc = UIHostingController(rootView: view)
        
        assertSnapshot(matching: vc, as: .image(on: .iPhone13ProMax))
    }
}
