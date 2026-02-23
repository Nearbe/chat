import SwiftUI
import SwiftData

/// Главная точка входа в приложение
@main
struct ChatApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ChatView()
                .modelContainer(persistenceController.container)
                .preferredColorScheme(ThemeManager.shared.colorScheme)
        }
    }
}
