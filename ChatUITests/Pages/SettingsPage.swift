// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.

import XCTest

/// Объект страницы для экрана настроек
@MainActor
final class SettingsPage {
    var root: XCUIElement {
        app.staticTexts["Настройки"]
    }
}
