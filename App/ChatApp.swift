// MARK: - Связь с документацией: Factory (Версия: 2.3.0). Статус: Синхронизировано.
import SwiftUI
import SwiftData
import Factory

/// - Документация: [Docs/Factory/README.md](../Docs/Factory/README.md)
/// Главная точка входа в приложение
@main
struct ChatApp: App {
    let persistenceController = PersistenceController.shared

    @Injected(\.sessionManager) private var sessionManager
    @Injected(\.chatService) private var chatService
    @Injected(\.networkMonitor) private var networkMonitor

    init() {
        #if DEBUG
        UITestModule.setupTestEnvironment()
        #endif
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
