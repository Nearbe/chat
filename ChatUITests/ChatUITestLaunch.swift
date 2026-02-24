// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.
import XCTest

@MainActor
final class ChatUITestLaunch: BaseTestCase {

    func testLaunch() async throws {
        step("Проверка запуска приложения") {
            XCTAssertTrue(app.exists)
        }
    }
}
