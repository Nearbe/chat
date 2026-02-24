// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.

import XCTest

/// Контексты приложения для специальных типов тестов
/// Аналог sheet/debugDescription для springboard, webview, safari, preferences
@MainActor
public enum ApplicationContexts {

    /// Springboard контекст (домашний экран iOS)
    public static var springboard: XCUIElement {
        XCUIApplication(bundleIdentifier: "com.apple.springboard")
    }

    /// Safari контекст
    public static var safari: XCUIElement {
        XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
    }

    /// Preferences контекст (Настройки iOS)
    public static var preferences: XCUIElement {
        XCUIApplication(bundleIdentifier: "com.apple.Preferences")
    }

    /// WebView в текущем приложении
    public static var currentWebView: XCUIElement {
        app.webViews.firstMatch
    }

    /// Sheet представление (iOS 15+)
    public static func sheet(identifier: String = "") -> XCUIElement {
        if identifier.isEmpty {
            return app.sheets.firstMatch
        }
        return app.sheets[identifier]
    }

    /// Alert представление
    public static var alert: XCUIElement {
        app.alerts.firstMatch
    }

    /// Action Sheet представление
    public static var actionSheet: XCUIElement {
        app.sheets.firstMatch
    }

    // MARK: - Debug Description Helpers

    /// Получить debugDescription для элемента
    public static func debugDescription(forelement: XCUIElement) -> String {
        var description = "Element: \(element.elementDebugDescription)\n"
        description += "Exists: \(element.exists)\n"
        description += "Visible: \(element.isHittable)\n"
        description += "Label: \(element.label)\n"
        description += "Value: \(element.value as ?String ?? "nil")\n"
        return description
    }

    /// Получить полную иерархию приложения
    public static func fullHierarchy() -> String {
        var hierarchy = "=== Application Hierarchy ===\n"
        hierarchy += "App: \(app.debugDescription)\n"
        hierarchy += "=== End Hierarchy ===\n"
        return hierarchy
    }

    /// Получить иерархию для webview
    public static func webViewHierarchy() -> String {
        var hierarchy = "=== WebView Hierarchy ===\n"
        for webView in app.webViews.allElementsBoundByIndex {
            hierarchy += "WebView[\(webView.hash)]: \(webView.debugDescription)\n"
        }
        hierarchy += "=== End WebView Hierarchy ===\n"
        return hierarchy
    }

    /// Логирование текущего состояния экрана
    public static func logScreenState(file: StaticString = #filePath, line: UInt = #line) {
        XCTContext.runActivity(named: "Screen State Debug") {
            activity in
            let hierarchy = XCTAttachment(string: fullHierarchy())
            hierarchy.name = "Screen Hierarchy"
            activity.add(hierarchy)

            let screenshot = XCTAttachment(screenshot: app.screenshot())
            screenshot.name = "Screen Screenshot"
            activity.add(screenshot)

            Logger.debug("Screen state logged: \(fullHierarchy())")
        }
    }
}
