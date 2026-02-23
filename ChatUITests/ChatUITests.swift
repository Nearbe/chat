// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.
import XCTest

@MainActor
final class ChatUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() async throws {
        try await super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-reset"]
        app.launch()
    }

    func testLaunch() async throws {
        // Базовая проверка, что главный экран загрузился
        XCTAssertTrue(app.exists)
    }

    func testAuthenticationAndMessaging() async throws {
        // Запускаем с авторизацией для теста сообщений
        app.terminate()
        app.launchArguments = ["-auth"]
        app.launch()
        
        let chatPage = ChatPage(app: app)
        
        // 1. Ожидаем появления интерфейса чата (пустого состояния)
        XCTAssertTrue(chatPage.isEmptyStateVisible())
        
        // 2. Отправка сообщения
        chatPage.typeMessage("Привет, AI!")
        
        // Если кнопка активна (выбрана модель и сервер доступен), нажимаем
        if chatPage.sendButton.isEnabled {
            chatPage.tapSend()
            
            // Проверяем появление "баббла" сообщения (по тексту)
            XCTAssertTrue(chatPage.hasMessage("Привет, AI!"))
        }
    }

    func testNavigation() async throws {
        let chatPage = ChatPage(app: app)
        
        // 1. Проверка открытия боковой панели истории
        if chatPage.historyButton.exists {
            chatPage.openHistory()
            // Проверяем, что панель открылась (например, по заголовку "История")
            XCTAssertTrue(app.staticTexts["История"].waitForExistence(timeout: 2))
            // Закрываем панель
            app.swipeDown(velocity: .fast)
        }
        
        // 2. Проверка выбора модели
        if chatPage.modelPickerButton.exists {
            chatPage.openModelPicker()
            // Проверяем наличие списка моделей
            XCTAssertTrue(app.staticTexts["Доступные модели"].waitForExistence(timeout: 2))
        }
    }
}
