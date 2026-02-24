// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.
import XCTest

@MainActor
final class ChatUITestAuth: BaseTestCase {

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
}
