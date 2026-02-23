// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.
import XCTest

/// Объект страницы для экрана чата
@MainActor
final class ChatPage {
    let app: XCUIApplication
    
    init(app: XCUIApplication) {
        self.app = app
    }
    
    // MARK: - Элементы
    
    var emptyStateText: XCUIElement {
        app.staticTexts["empty_state_text"]
    }
    
    var messageInputField: XCUIElement {
        app.descendants(matching: .any)["message_input_field"]
    }
    
    var sendButton: XCUIElement {
        app.buttons["send_button"]
    }
    
    var historyButton: XCUIElement {
        app.buttons["История чатов"]
    }
    
    var modelPickerButton: XCUIElement {
        app.buttons["Выбор модели"]
    }
    
    // MARK: - Действия
    
    @discardableResult
    func typeMessage(_ text: String) -> Self {
        messageInputField.tap()
        messageInputField.typeText(text)
        return self
    }
    
    @discardableResult
    func tapSend() -> Self {
        sendButton.tap()
        return self
    }
    
    @discardableResult
    func openHistory() -> Self {
        historyButton.tap()
        return self
    }
    
    @discardableResult
    func openModelPicker() -> Self {
        modelPickerButton.tap()
        return self
    }
    
    // MARK: - Проверки
    
    func hasMessage(_ text: String, timeout: TimeInterval = 3) -> Bool {
        app.staticTexts[text].waitForExistence(timeout: timeout)
    }
    
    func isEmptyStateVisible(timeout: TimeInterval = 5) -> Bool {
        emptyStateText.waitForExistence(timeout: timeout)
    }
}
