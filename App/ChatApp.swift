import SwiftUI
import SwiftData
import Factory

/// Главная точка входа в приложение
@main
struct ChatApp: App {
    let persistenceController = PersistenceController.shared
    
    @Injected(\.sessionManager) private var sessionManager
    @Injected(\.chatService) private var chatService
    @Injected(\.networkMonitor) private var networkMonitor
    
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
