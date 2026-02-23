import SwiftUI
import SwiftData

/// Главная точка входа в приложение
@main
struct ChatApp: App {
    let persistenceController = PersistenceController.shared
    
    // Создаем сервисы
    private let sessionManager: ChatSessionManager
    private let chatService: ChatService
    private let networkMonitor: NetworkMonitor
    
    init() {
        let context = persistenceController.mainContext
        self.sessionManager = ChatSessionManager(modelContext: context)
        
        let networkService = NetworkService(deviceName: DeviceIdentity.currentName)
        self.chatService = ChatService(networkService: networkService)
        self.networkMonitor = NetworkMonitor()
    }

    var body: some Scene {
        WindowGroup {
            ChatView()
                .modelContainer(persistenceController.container)
                .preferredColorScheme(ThemeManager.shared.colorScheme)
                .environmentObject(sessionManager)
                .environmentObject(chatService)
                .environmentObject(networkMonitor)
        }
    }
}
