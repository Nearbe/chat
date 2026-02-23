// MARK: - Связь с документацией: SnapshotTesting (Версия: 1.15.4). Статус: Синхронизировано.
import XCTest
import SwiftUI
import SnapshotTesting
@testable import Chat

@MainActor
final class ChatSnapshotTests: XCTestCase {
    
    override func setUp() async throws {
        try await super.setUp()
        // isRecording = true // Раскомментируйте, чтобы обновить снапшоты
    }
    
    func testChatViewDefault() async {
        let container = TestHelpers.createInMemoryContainer()
        let sessionManager = ChatSessionManager(modelContext: container.mainContext)
        let networkService = NetworkService()
        let chatService = ChatService(networkService: networkService)
        
        let view = ChatView()
            .environmentObject(sessionManager)
            .environmentObject(chatService)
            .environmentObject(NetworkMonitor())
        
        let vc = UIHostingController(rootView: view)
        
        assertSnapshot(of: vc, as: .image(on: .iPhone16ProMax))
    }
    
    func testChatViewDarkMode() async {
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
        
        assertSnapshot(of: vc, as: .image(on: .iPhone16ProMax))
    }
    
    func testChatViewWithDynamicType() async {
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
        
        assertSnapshot(of: vc, as: .image(on: .iPhone16ProMax))
    }
}
