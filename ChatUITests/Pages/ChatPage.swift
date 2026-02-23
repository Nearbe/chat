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
    /// Ввод сообщения в текстовое поле.
    func typeMessage(_ text: String) -> Self {
        messageInputField.type(text)
        return self
    }
    
    @discardableResult
    /// Нажатие кнопки отправки.
    func tapSend() -> Self {
        sendButton.tap()
        return self
    }
    
    @discardableResult
    /// Переход к экрану истории.
    func openHistory() -> Self {
        historyButton.tap()
        return self
    }
    
    @discardableResult
    /// Открытие списка выбора моделей.
    func openModelPicker() -> Self {
        modelPickerButton.tap()
        return self
    }
    
    // MARK: - Проверки
    
    /// Проверка наличия сообщения в списке.
    func checkHasMessage(_ text: String) {
        BaseElement(app.staticTexts[text]).check(exists: true)
    }
    
    /// Проверка видимости пустого состояния экрана.
    func checkEmptyStateVisible() {
        emptyStateText.check(exists: true)
    }
}
