// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.

import XCTest

/// Базовый класс экрана (Page Object)
/// Аналог UTBaseScreen из tx-mobile
@MainActor
public class BaseScreen: BaseElement {

    public var isWaitForExistence: Bool
    public var timeout: TimeInterval

    /// Статический экземпляр экрана (singleton pattern)
    public static var screen: BaseScreen {
        BaseScreen(Self.defaultElement)
    }

    /// Метод для получения нового экземпляра экрана
    public static func screenInstance() -> BaseScreen {
        BaseScreen(Self.defaultElement)
    }

    /// Дефолтный элемент экрана - должен быть переопределен в наследниках
    public static var defaultElement: XCUIElement {
        fatalError("Необходимо переопределить defaultElement в \(String(describing: self))")
    }

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

    // MARK: - Fluent API

    /// Установить waitForExistence
    @discardableResult
    public func set(waitForExistence: Bool) -> Self {
        self.isWaitForExistence = waitForExistence
        return self
    }

    /// Установить timeout
    @discardableResult
    public func set(timeout: TimeInterval) -> Self {
        self.timeout = timeout
        return self
    }

    // MARK: - Проверки

    /// Проверить что экран отображается
    @discardableResult
    public func checkDisplayed(file: StaticString = #filePath, line: UInt = #line) -> Self {
        XCTContext.runActivity(named: "Проверка отображения экрана: \(type(of: self))") {
            _ in
            XCTAssertTrue(element.exists, "Экран \(type(of: self)) не отображается", file: file, line: line)
        }
        return self
    }

    /// Проверить что экран не отображается
    @discardableResult
    public func checkNotDisplayed(file: StaticString = #filePath, line: UInt = #line) -> Self {
        XCTContext.runActivity(named: "Проверка отсутствия экрана: \(type(of: self))") {
            _ in
            XCTAssertFalse(element.exists, "Экран \(type(of: self)) все еще отображается", file: file, line: line)
        }
        return self
    }
}
