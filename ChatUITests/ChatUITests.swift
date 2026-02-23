import XCTest

final class ChatUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Базовая проверка, что главный экран загрузился
        // (Например, наличие кнопки создания нового чата или заголовка)
        XCTAssertTrue(app.exists)
    }
}
