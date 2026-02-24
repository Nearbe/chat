// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.

import XCTest

/// Шаги для работы с настройками
@MainActor
public final class SettingsSteps {

    // MARK: - Свойства

    private let settingsPage = SettingsPage()

    // MARK: - Навигация

    /// Открытие настроек
    @discardableResult
    public func openSettings() -> SettingsSteps {
        XCTContext.runActivity(named: "Открытие настроек") {
            _ in
            // Навигация к настройкам
        }
        return self
    }

    // MARK: - Действия

    /// Установка API URL
    @discardableResult
    public func setAPIURL(_ url: String) -> SettingsSteps {
        XCTContext.runActivity(named: "Установка API URL: \(url)") {
            _ in
            settingsPage.setAPIURL(url)
        }
        return self
    }

    /// Очистка кэша
    @discardableResult
    public func clearCache() -> SettingsSteps {
        XCTContext.runActivity(named: "Очистка кэша") {
            _ in
            settingsPage.clearCache()
        }
        return self
    }

    /// Открытие информации о приложении
    @discardableResult
    public func openAbout() -> SettingsSteps {
        XCTContext.runActivity(named: "Открытие информации о приложении") {
            _ in
            settingsPage.openAbout()
        }
        return self
    }

    // MARK: - Проверки

    /// Проверка API URL
    @discardableResult
    public func verifyAPIURL(_ url: String) -> SettingsSteps {
        XCTContext.runActivity(named: "Проверка API URL") {
            _ in
            settingsPage.checkAPIURL(url)
        }
        return self
    }
}

/// Глобальный экземпляр
public var settingsSteps: SettingsSteps {
    SettingsSteps()
}
