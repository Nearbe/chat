// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.
import XCTest

@MainActor
final class ChatUITestNavigation: BaseTestCase {

    override func setUp() async throws {
        try await super.setUp()
    }

    func testNavigation() async throws {
        let chatPage = ChatPage()

        step("Проверка боковой панели истории") {
            if chatPage.historyButton.element.exists {
                chatPage.openHistory()
                XCTAssertTrue(app.staticTexts["История"].waitForExistence(timeout: elementTimeout))
                app.swipeDown(velocity: .fast)
            }
        }

        step("Проверка выбора модели") {
            if chatPage.modelPickerButton.element.exists {
                chatPage.openModelPicker()
                XCTAssertTrue(app.staticTexts["Доступные модели"].waitForExistence(timeout: elementTimeout))
            }
        }
    }
}
