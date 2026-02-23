// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.
import XCTest

@MainActor
final class ChatUITests: BaseTestCase {

    func testLaunch() async throws {
        step("Проверка запуска приложения") {
            XCTAssertTrue(app.exists)
        }
    }

    func testAuthenticationAndMessaging() async throws {
        step("Перезапуск с авторизацией") {
            app.terminate()
            app.launchArguments = ["-ui-tests", "-auth"]
            app.launch()
        }
        
        let chatPage = ChatPage()
        
        step("Отправка сообщения") {
            chatPage.checkEmptyStateVisible()
            chatPage.typeMessage("Привет, AI!")
            
            if chatPage.sendButton.element.isEnabled {
                chatPage.tapSend()
                chatPage.checkHasMessage("Привет, AI!")
            }
        }
    }

    func testNavigation() async throws {
        let chatPage = ChatPage()
        
        step("Проверка боковой панели истории") {
            if chatPage.historyButton.element.exists {
                chatPage.openHistory()
                XCTAssertTrue(app.staticTexts["История"].waitForExistence(timeout: 2))
                app.swipeDown(velocity: .fast)
            }
        }
        
        step("Проверка выбора модели") {
            if chatPage.modelPickerButton.element.exists {
                chatPage.openModelPicker()
                XCTAssertTrue(app.staticTexts["Доступные модели"].waitForExistence(timeout: 2))
            }
        }
    }
}
