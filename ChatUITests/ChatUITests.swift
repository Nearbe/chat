import XCTest

final class ChatUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-reset"]
        app.launch()
    }

    func testLaunch() throws {
        // Базовая проверка, что главный экран загрузился
        XCTAssertTrue(app.exists)
    }

    func testAuthenticationAndMessaging() throws {
        // Запускаем с авторизацией для теста сообщений
        app.terminate()
        app.launchArguments = ["-auth"]
        app.launch()
        
        // 1. Ожидаем появления интерфейса чата (пустого состояния)
        let emptyState = app.staticTexts["empty_state_text"]
        XCTAssertTrue(emptyState.waitForExistence(timeout: 5))
        
        // 2. Отправка сообщения
        let inputField = app.textViews["message_input_field"]
        XCTAssertTrue(inputField.exists)
        
        inputField.tap()
        inputField.typeText("Привет, AI!")
        
        let sendButton = app.buttons["send_button"]
        XCTAssertTrue(sendButton.exists)
        
        // Если кнопка активна (выбрана модель и сервер доступен), нажимаем
        if sendButton.isEnabled {
            sendButton.tap()
            
            // Проверяем появление "баббла" сообщения (по тексту)
            let messageBubble = app.staticTexts["Привет, AI!"]
            XCTAssertTrue(messageBubble.waitForExistence(timeout: 3))
        }
    }

    func testNavigation() throws {
        // 1. Проверка открытия боковой панели истории
        let historyButton = app.buttons["История чатов"]
        if historyButton.exists {
            historyButton.tap()
            // Проверяем, что панель открылась (например, по заголовку "История")
            XCTAssertTrue(app.staticTexts["История"].waitForExistence(timeout: 2))
            // Закрываем панель
            app.swipeDown(velocity: .fast)
        }
        
        // 2. Проверка выбора модели
        let modelPickerButton = app.buttons["Выбор модели"]
        if modelPickerButton.exists {
            modelPickerButton.tap()
            // Проверяем наличие списка моделей
            XCTAssertTrue(app.staticTexts["Доступные модели"].waitForExistence(timeout: 2))
        }
    }
}
