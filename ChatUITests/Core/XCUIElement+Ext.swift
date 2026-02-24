// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.

import Foundation
import UIKit
import XCTest

/// Расширения для XCUIElement - зеркалируют методы из BaseElement
/// Позволяют использовать断言 и ожидания напрямую на XCUIElement
public extension XCUIElement {

    // MARK: - Ожидания

    /// Ожидать появления элемента
    func waitForExistence(timeout seconds: TimeInterval = elementTimeout, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssert(waitForExistence(timeout: seconds), file: file, line: line)
    }

    /// Ожидать исчезновения элемента
    func waitForNotExistence(timeout seconds: TimeInterval = elementTimeout, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssert(!waitForExistence(timeout: seconds), file: file, line: line)
    }

    /// Ожидать выполнения предиката
    func wait(forpredicate: Predicates, timeout seconds: TimeInterval = elementTimeout) {
        XCTWaiter().wait(for: XCTNSPredicateExpectation(predicate: predicate.get(), object: self), timeout: seconds)
    }

    // MARK: - Assertions (check)

    /// Проверить title
    func check(title: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(self.title, title, file: file, line: line)
    }

    /// Проверить label
    func check(label: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(self.label, label, file: file, line: line)
    }

    /// Проверить value
    func check(value: String?, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(self.value as ?String, value, file: file, line: line)
    }

    /// Проверить отличие от theme
    func check(theme: String?, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertNotEqual(self.value as ?String, theme, file: file, line: line)
    }

    /// Проверить placeholder
    func check(placeholder: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(self.placeholderValue, placeholder, file: file, line: line)
    }

    /// Проверить enabled
    func check(enabled: Bool, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(self.isEnabled, enabled, file: file, line: line)
    }

    /// Проверить selected
    func check(selected: Bool, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(self.isSelected, selected, file: file, line: line)
    }

    /// Проверить exists
    func check(exists: Bool, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(self.exists, exists, file: file, line: line)
    }

    // MARK: - Contains assertions

    /// Проверить содержит title
    func contains(title: String, file: StaticString = #filePath, line: UInt = #line) {
        let expression = self.title.contains(title)
        let message = "Title: \(self.title) doesn't contain: \(title)"
        XCTAssert(expression, message, file: file, line: line)
    }

    /// Проверить содержит label
    func contains(label: String, file: StaticString = #filePath, line: UInt = #line) {
        let expression = self.label.contains(label)
        let message = "Label: \(self.label) doesn't contain: \(label)"
        XCTAssert(expression, message, file: file, line: line)
    }

    /// Проверить содержит один из labels
    func contains(anyOfLabels labels: [String], file: StaticString = #filePath, line: UInt = #line) {
        let expression = labels.contains {
            self.label.contains($0)
        }
        let message = "Label: \(self.label) doesn't contain any of: \(labels.joined(separator: ", "))"
        XCTAssert(expression, message, file: file, line: line)
    }

    /// Проверить содержит value
    func contains(value: String, file: StaticString = #filePath, line: UInt = #line) {
        let expression = "\(self.value ?? "")".contains(value)
        let message = "Value: \(self.value ?? "") doesn't contain: \(value)"
        XCTAssert(expression, message, file: file, line: line)
    }

    /// Проверить содержит placeholder
    func contains(placeholder: String, file: StaticString = #filePath, line: UInt = #line) {
        let expression = "\(self.placeholderValue ?? "")".contains(placeholder)
        let message = "Placeholder Value: \(self.placeholderValue ?? "") doesn't contain: \(placeholder)"
        XCTAssert(expression, message, file: file, line: line)
    }

    // MARK: - Does not contain assertions

    /// Проверить не содержит title
    func doesNotContain(title: String, file: StaticString = #filePath, line: UInt = #line) {
        let expression = self.title.contains(title)
        let message = "Title: \(self.title) contains: \(title), but should not"
        XCTAssertFalse(expression, message, file: file, line: line)
    }

    /// Проверить не содержит label
    func doesNotContain(label: String, file: StaticString = #filePath, line: UInt = #line) {
        let expression = self.label.contains(label)
        let message = "Label: \(self.label) contains: \(label), but should not"
        XCTAssertFalse(expression, message, file: file, line: line)
    }

    /// Проверить не содержит value
    func doesNotContain(value: String, file: StaticString = #filePath, line: UInt = #line) {
        let expression = "\(self.value ?? "")".contains(value)
        let message = "Value: \(self.value ?? "") contains: \(value), but should not"
        XCTAssertFalse(expression, message, file: file, line: line)
    }

    /// Проверить не содержит placeholder
    func doesNotContain(placeholder: String, file: StaticString = #filePath, line: UInt = #line) {
        let expression = "\(self.placeholderValue ?? "")".contains(placeholder)
        let message = "Placeholder Value: \(self.placeholderValue ?? "") contains: \(placeholder), but should not"
        XCTAssertFalse(expression, message, file: file, line: line)
    }

    // MARK: - Действия

    /// Вставить текст через буфер обмена
    func paste(text: String, isForceClick: Bool = false) {
        UIPasteboard.general.string = text
        click(force: isForceClick)
        press(forDuration: 0.5)
        contextMenu.pasteButton.tap()
    }

    /// Ввести текст
    func type(text: String, isForceClick: Bool = false) {
        click(force: isForceClick)
        typeText(text)
    }

    /// Очистить текстовое поле
    func clear(isForceClick: Bool = false) {
        click(force: isForceClick)
        let maxAttempts = 3
        for _ in 0 ..< maxAttempts {
            guard let value = self.value as ?String, !value.isEmpty else {
                return
            }
            typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: value.count))
        }
    }

    /// Кликнуть по элементу
    func click(force: Bool = false) {
        if force {
            coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        } else {
            tap()
        }
    }

    /// Долгое нажатие
    func press(forduration: TimeInterval = 1.0) {
        press(forDuration: duration)
    }

    /// Выбрать значение в пикере
    func pick(column: Int, value: String) {
        pickerWheels.allElementsBoundByIndex[column].adjust(toPickerWheelValue: value)
    }

    // MARK: - Scroll

    /// Скролл к элементу
    func scrollToElement(_ element: XCUIElement, scrollDirection: SwipeDirection = .up) {
        for _ in 0 ..< 10 {
            if element.exists {
                return
            }
            switch scrollDirection {
            case .up:
                swipeUp()
            case .down:
                swipeDown()
            case .left:
                swipeLeft()
            case .right:
                swipeRight()
            }
        }
    }

    /// Направление скролла
    enum SwipeDirection {
        case up , down , left , right
    }

    // MARK: - Tap Forced

    /// Тап с усилием
    func tapForced(force: Bool) {
        if force {
            coordinate(withNormalizedOffset: CGVector(dx: 0.0, dy: 0.0)).tap()
        } else {
            tap()
        }
    }

    // MARK: - Collection Helpers

    /// Получить первый элемент
    var firstElement: XCUIElement {
        return self.allElementsBoundByIndex.first ?? self
    }

    // MARK: - Context Menu

    /// Контекстное меню (если доступно)
    var contextMenu: XCUIElement {
        return self.containing(NSPredicate(format: "label CONTAINS[c] 'Copy' OR label CONTAINS[c] 'Paste' OR label CONTAINS[c] 'Select'"))
    }

    /// Кнопка Paste в контекстном меню
    var pasteButton: XCUIElement {
        return self.buttons["Paste"]
    }
}
