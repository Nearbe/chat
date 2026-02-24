// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.

import XCTest

/// Наблюдатель за тестами - автоматически логирует начало и конец каждого теста
/// Аналог UTTestObserver из tx-mobile
@MainActor
public final class UTTestObserver: NSObject, XCTestObserver {

    /// Включен ли observer
    public var isEnabled: Bool = true

    public override init() {
        super.init()
    }

    // MARK: - XCTestObserver

    public func testCaseWillStart(_ testCase: XCTestCase) {
        guard isEnabled else {
            return
        }
        let testName = String(describing: testCase.name)
        Logger.info("🧪 Начало теста: \(testName)")
    }

    public func testCase(_ testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: Int) {
        guard isEnabled else {
            return
        }
        let testName = String(describing: testCase.name)
        Logger.error("❌ Тест упал: \(testName) - \(description)")

        // Дополнительная информация о приложении при падении
        if app.exists {
            let hierarchy = app.debugDescription
            Logger.debug("UI Hierarchy:\n\(hierarchy)")
        }
    }

    public func testCaseDidFinish(_ testCase: XCTestCase) {
        guard isEnabled else {
            return
        }
        let testName = String(describing: testCase.name)
        let duration = testCase.testRun?.totalDuration ?? 0
        Logger.info("✅ Тест завершён: \(testName) (duration: \(String(format: "%.2f", duration))s)")
    }

    public func testSuiteWillStart(_ testSuite: XCTestSuite) {
        guard isEnabled else {
            return
        }
        Logger.info("📋 Начало набора тестов: \(testSuite.name)")
    }

    public func testSuiteDidFinish(_ testSuite: XCTestSuite) {
        guard isEnabled else {
            return
        }
        Logger.info("📋 Набор тестов завершён: \(testSuite.name)")
    }

    // MARK: - Data Collection

    /// Собрать данные при падении теста
    public func collectFailureData(fortestCase: XCTestCase) -> [String: Any] {
        var data: [String: Any] = [
            "testName": String(describing: testCase.name),
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]

        if app.exists {
            data["appDescription"] = app.debugDescription
            data["screenshot"] = app.screenshot().pngRepresentation
        }

        return data
    }
}

/// Глобальный экземпляр observer
@MainActor
public let testObserver = UTTestObserver()
