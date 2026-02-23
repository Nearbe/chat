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
    
    init() {
        if ProcessInfo.processInfo.arguments.contains("-reset") {
            // Очищаем токен для тестирования экрана авторизации
            if let config = DeviceConfiguration.configuration(for: DeviceIdentity.currentName) {
                _ = KeychainHelper.delete(key: config.tokenKey)
            }
        } else if ProcessInfo.processInfo.arguments.contains("-auth") {
            // Устанавливаем тестовый токен для прохождения UI тестов
            if let config = DeviceConfiguration.configuration(for: DeviceIdentity.currentName) {
                _ = KeychainHelper.set(key: config.tokenKey, value: "sk-lm-test-token")
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
