// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.
import XCTest

/// Объект страницы для экрана чата
@MainActor
final class ChatPage {
    
    // MARK: - Элементы
    
    var emptyStateText: BaseElement {
        BaseElement(app.staticTexts["empty_state_text"])
    }
    
    var messageInputField: BaseElement {
        BaseElement(app.descendants(matching: .any)["message_input_field"])
    }
    
    var sendButton: BaseElement {
        // Для кнопок, которые могут быть неактивны, отключаем ожидание в init
        BaseElement(app.buttons["send_button"], waitForExistence: false)
    }
    
    var historyButton: BaseElement {
        BaseElement(app.buttons["История чатов"], waitForExistence: false)
    }
    
    var modelPickerButton: BaseElement {
        BaseElement(app.buttons["Выбор модели"], waitForExistence: false)
    }
    
    // MARK: - Действия
    
    @discardableResult
    func typeMessage(_ text: String) -> Self {
        messageInputField.type(text)
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
    
    func checkHasMessage(_ text: String) {
        BaseElement(app.staticTexts[text]).check(exists: true)
    }
    
    func checkEmptyStateVisible() {
        emptyStateText.check(exists: true)
    }
}
