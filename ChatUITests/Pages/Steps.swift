// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.

import XCTest

/// Глобальные экземпляры step classes для Pages директории
/// Соответствует требованию global variables для steps instances в Pages/
@MainActor
public enum Steps {

    /// Экземпляр ChatSteps
    public static var chat: ChatSteps {
        ChatSteps()
    }

    /// Экземпляр SettingsSteps
    public static var settings: SettingsSteps {
        SettingsSteps()
    }

    /// Создать экземпляр ChatSteps
    public static func chatSteps() -> ChatSteps {
        ChatSteps()
    }

    /// Создать экземпляр SettingsSteps
    public static func settingsSteps() -> SettingsSteps {
        SettingsSteps()
    }
}

// MARK: - Legacy Global Variables

/// Глобальный экземпляр ChatSteps (для обратной совместимости)
@MainActor
public var chatStepsInstance: ChatSteps {
    ChatSteps()
}

/// Глобальный экземпляр SettingsSteps (для обратной совместимости)
@MainActor
public var settingsStepsInstance: SettingsSteps {
    SettingsSteps()
}
