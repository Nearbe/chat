// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.

import XCTest

/// Объект страницы для экрана настроек
@MainActor
final class SettingsPage {
    var root: XCUIElement {
        app.staticTexts["Настройки"]
    }

    // MARK: - Элементы

    private var urlTextField: XCUIElement {
        app.textFields["api_url_textfield"]
    }

    private var clearCacheButton: XCUIElement {
        app.buttons["clear_cache_button"]
    }

    private var aboutButton: XCUIElement {
        app.buttons["about_button"]
    }

    // MARK: - Действия

    func setAPIURL(_ url: String) {
        XCTContext.runActivity(named: "Ввод URL: \(url)") {
            _ in
            urlTextField.tap()
            urlTextField.typeText(url)
        }
    }

    func clearCache() {
        XCTContext.runActivity(named: "Очистка кэша") {
            _ in
            clearCacheButton.tap()
            // Подтверждение очистки, если требуется
            if app.alerts.element.exists {
                app.buttons["Очистить"].tap()
            }
        }
    }

    func openAbout() {
        XCTContext.runActivity(named: "Открытие раздела О приложении") {
            _ in
            aboutButton.tap()
        }
    }

    // MARK: - Проверки

    func checkAPIURL(_ url: String) {
        XCTContext.runActivity(named: "Проверка URL: \(url)") {
            _ in
            XCTAssertTrue(urlTextField.value as ?String == url, "URL не соответствует ожидаемому")
        }
    }
}
