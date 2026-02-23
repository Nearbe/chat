// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.
import XCTest

@MainActor
final class ChatUITestLaunch: BaseTestCase {

    override func setUp() async throws {
        try await super.setUp()
    }

    func testLaunch() async throws {
        step("Проверка запуска приложения") {
            XCTAssertTrue(app.exists)
        }
    }
}
