// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.

import XCTest

@MainActor
final class ChatUITests: BaseTestCase {

    /// Тест отправки сообщения без авторизации
    func testSendMessageWithoutAuth() async throws {
        // Используем testConfiguration() builder для настройки теста
        _ = testConfiguration().metaData("FTD-T5338", name: "testSendMessageWithoutAuth", suite: "Chat").authorization(.none).animations(false).clearState(true).startScreen(.chat).apiURL("http://192.168.1.91:64721").build()

        step("Отправка сообщения без авторизации") {
            let chatPage = ChatPage()

            chatPage.checkEmptyStateVisible()
            chatPage.typeMessage("Привет, AI!")

            if chatPage.sendButton.element.isEnabled {
                chatPage.tapSend()
                chatPage.checkHasMessage("Привет, AI!")
            }
        }
    }
}
