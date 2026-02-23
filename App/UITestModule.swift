// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import Foundation
import SwiftData

#if DEBUG
/// Модуль для управления состоянием приложения из UI-тестов
enum UITestModule {

    static var isUITestingEnabled: Bool {
        ProcessInfo.processInfo.arguments.contains("-ui-tests")
    }

    static var shouldResetState: Bool {
        ProcessInfo.processInfo.arguments.contains("-reset")
    }

    static var shouldMockAuth: Bool {
        ProcessInfo.processInfo.arguments.contains("-auth")
    }

    static var isAnimationsDisabled: Bool {
        ProcessInfo.processInfo.environment["Animations"] == "false"
    }

    /// Выполняет начальную настройку приложения для тестов
    @MainActor
    static func setupTestEnvironment() {
        guard isUITestingEnabled else { return }

        if isAnimationsDisabled {
            // В SwiftUI нет прямого способа отключить все анимации глобально через UIView,
            // но мы можем повлиять на транзакции или проверять этот флаг в компонентах.
            // Для UIKit это было бы: UIView.setAnimationsEnabled(false)
        }

        if shouldResetState {
            // Очистка данных
            let tokenKey = "auth_token_test" // Упрощенно для примера, в идеале брать из конфига
            KeychainHelper.delete(key: tokenKey)
            PersistenceController.shared.deleteAll()
        }

        if shouldMockAuth {
            // Здесь можно добавить логику автоматической авторизации
        }
    }
}
#endif
