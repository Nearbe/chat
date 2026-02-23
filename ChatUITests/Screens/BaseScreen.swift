// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.

import XCTest

/// Базовый класс экрана (Page Object)
/// Аналог UTBaseScreen из tx-mobile
@MainActor
public class BaseScreen: BaseElement {

    public var isWaitForExistence: Bool
    public var timeout: TimeInterval

    public init(
        _ element: XCUIElement,
        isWaitForExistence: Bool = true,
        timeout: TimeInterval = elementTimeout,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        self.isWaitForExistence = isWaitForExistence
        self.timeout = timeout
        super.init(element, waitForExistence: isWaitForExistence, timeout: timeout, file: file, line: line)
    }
}
