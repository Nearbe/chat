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
        let args = ProcessInfo.processInfo.arguments
        let tokenKey = DeviceConfiguration.configuration(for: DeviceIdentity.currentName)?.tokenKey ?? "auth_token_test"
        
        if args.contains("-reset") {
            // Очищаем токен для тестирования экрана авторизации
            KeychainHelper.delete(key: tokenKey)
            // И очищаем базу данных
            Task { @MainActor in
                PersistenceController.shared.deleteAll()
            }
        }
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
