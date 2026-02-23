// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.
import XCTest

@MainActor
open class BaseTestCase: XCTestCase {
    
    override open func setUp() async throws {
        try await super.setUp()
        continueAfterFailure = false
        
        step("Запуск приложения") {
            app.launchArguments = ["-ui-tests", "-reset"]
            app.launchEnvironment["Animations"] = "false"
            app.launch()
        }
    }
    
    override open func tearDown() async throws {
        if let failureCount = testRun?.failureCount, failureCount > 0 {
            step("Сбор данных при падении") {
                // Иерархия элементов
                let hierarchy = XCTAttachment(string: app.debugDescription)
                hierarchy.name = "UI Hierarchy"
                hierarchy.lifetime = .keepAlways
                add(hierarchy)
                
                // Скриншот
                let screenshot = app.screenshot()
                let attachment = XCTAttachment(screenshot: screenshot)
                attachment.name = "Screenshot on Failure"
                attachment.lifetime = .keepAlways
                add(attachment)
            }
        }
        try await super.tearDown()
    }
}
