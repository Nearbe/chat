// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.
import XCTest

/// Обертка над XCUIElement для автоматизации ожиданий и повышения стабильности
@MainActor
public class BaseElement {
    public let element: XCUIElement
    private let file: StaticString
    private let line: UInt

    public init(_ element: XCUIElement, 
                waitForExistence: Bool = true, 
                timeout: TimeInterval = defaultTimeout,
                file: StaticString = #filePath, 
                line: UInt = #line) {
        self.element = element
        self.file = file
        self.line = line
        
        if waitForExistence {
            XCTContext.runActivity(named: "Ожидание элемента: \(element.description)") { _ in
                if !element.waitForExistence(timeout: timeout) {
                    XCTFail("Элемент не появился за \(timeout)с: \(element.description)", file: file, line: line)
                }
            }
        }
    }

    public func tap(file: StaticString = #filePath, line: UInt = #line) {
        XCTContext.runActivity(named: "Тап по элементу: \(element.description)") { _ in
            element.tap()
        }
    }

    public func type(_ text: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTContext.runActivity(named: "Ввод текста '\(text)' в: \(element.description)") { _ in
            element.tap()
            element.typeText(text)
        }
    }

    public func check(exists: Bool, timeout: TimeInterval = defaultTimeout, file: StaticString = #filePath, line: UInt = #line) {
        XCTContext.runActivity(named: "Проверка \(exists ? "наличия" : "отсутствия") элемента: \(element.description)") { _ in
            let result = exists ? element.waitForExistence(timeout: timeout) : !element.exists
            if !result {
                XCTFail("Ошибка проверки: элемент \(exists ? "не найден" : "все еще существует")", file: file, line: line)
            }
        }
    }
}
