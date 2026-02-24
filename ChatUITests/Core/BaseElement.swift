// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.

import UIKit
import XCTest

/// Обертка над XCUIElement для автоматизации ожиданий и повышения стабильности
@MainActor
public class BaseElement {
    /// Оригинальный XCUIElement
    public let element: XCUIElement
    private let file: StaticString
    private let line: UInt
    /// Таймаут по умолчанию для действий с элементом
    public let elementTimeout: TimeInterval

    /// Инициализация обертки для элемента
    public init(_ element: XCUIElement,
    waitForExistence: Bool = true,
    timeout: TimeInterval = defaultTimeout,
    file: StaticString = #filePath,
    line: UInt = #line) {
        self.element = element
        self.file = file
        self.line = line
        self.elementTimeout = timeout

        if waitForExistence {
            XCTContext.runActivity(named: "Ожидание элемента: \(element.description)") { _ in
                if !element.waitForExistence(timeout: timeout) {
                    XCTFail("Элемент не появился за \(timeout)с: \(element.description)", file: file, line: line)
                }
            }
        }
    }

    // MARK: - Свойства

    /// Элемент существует.
    public var exists: Bool {
        element.exists
    }

    /// Label элемента.
    public var label: String {
        element.label
    }

    /// Identifier элемента.
    public var identifier: String {
        element.identifier
    }

    /// Тип элемента.
    public var elementType: XCUIElement.ElementType {
        element.elementType
    }

    /// Элемент видим (существует и доступен для тапа).
    public var isVisible: Bool {
        element.exists && element.isHittable
    }

    /// Value элемента.
    public var value: String? {
        element.value as ?String
    }

    /// Элемент включен.
    public var isEnabled: Bool {
        element.isEnabled
    }

    /// Элемент выбран.
    public var isSelected: Bool {
        element.isSelected
    }

    /// Элемент имеет фокус клавиатуры.
    public var hasFocus: Bool {
        element.hasFocus
    }

    /// Placeholder элемента.
    public var placeholderValue: String? {
        element.placeholderValue
    }

    // MARK: - Основные действия

    /// Нажатие на элемент.
    @discardableResult
    public func tap(file: StaticString = #filePath, line: UInt = #line) -> BaseElement {
        XCTContext.runActivity(named: "Тап по элементу: \(element.description)") { _ in
            element.tap()
        }
        return self
    }

    /// Нажатие с усилием.
    @discardableResult
    public func tap(force: Bool, file: StaticString = #filePath, line: UInt = #line) -> BaseElement {
        XCTContext.runActivity(named: "Тап по элементу с force=\(force): \(element.description)") {
            _ in
            element.tapForced(force: force)
        }
        return self
    }

    /// Ввод текста в элемент.
    @discardableResult
    public func type(_ text: String, isForceClick: Bool = false, file: StaticString = #filePath, line: UInt = #line) -> BaseElement {
        XCTContext.runActivity(named: "Ввод текста '\(text)' в: \(element.description)") { _ in
            if isForceClick {
                element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            } else {
                element.tap()
            }
            element.typeText(text)
        }
        return self
    }

    /// Очистка текста в элементе.
    @discardableResult
    public func clear(isForceClick: Bool = false, file: StaticString = #filePath, line: UInt = #line) -> BaseElement {
        XCTContext.runActivity(named: "Очистка элемента: \(element.description)") {
            _ in
            if isForceClick {
                element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            } else {
                element.tap()
            }
            element.tap()
            if let currentValue = element.value as ?String, !currentValue.isEmpty {
                let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: currentValue.count)
                element.typeText(deleteString)
            }
        }
        return self
    }

    /// Вставка текста из буфера обмена.
    @discardableResult
    public func paste(_ text: String, isForceClick: Bool = false, file: StaticString = #filePath, line: UInt = #line) -> BaseElement {
        XCTContext.runActivity(named: "Вставка текста: \(element.description)") {
            _ in
            UIPasteboard.general.string = text
            if isForceClick {
                element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            } else {
                element.tap()
            }
            element.press(forDuration: 1.0)
            element.menuItems["Вставить"].tap()
        }
        return self
    }

    /// Удержание элемента.
    @discardableResult
    public func press(forDuration duration: TimeInterval, file: StaticString = #filePath, line: UInt = #line) -> BaseElement {
        XCTContext.runActivity(named: "Удержание элемента \(duration)с: \(element.description)") {
            _ in
            element.press(forDuration: duration)
        }
        return self
    }

    /// Выбор значения на Picker Wheel.
    @discardableResult
    public func adjust(toPickerWheelValue value: String, file: StaticString = #filePath, line: UInt = #line) -> BaseElement {
        XCTContext.runActivity(named: "Установка Picker Wheel значение: \(value)") {
            _ in
            element.pickerWheels[value].adjust(toPickerWheelValue: value)
        }
        return self
    }

    /// Выбор значения в picker.
    @discardableResult
    public func pick(column: Int, value: String, file: StaticString = #filePath, line: UInt = #line) -> BaseElement {
        XCTContext.runActivity(named: "Выбор picker: column=\(column), value=\(value)") {
            _ in
            element.pickerWheels.fixedSpaces.element(boundBy: column).adjust(toPickerWheelValue: value)
        }
        return self
    }

    // MARK: - Swipe

    /// Свайп вверх.
    @discardableResult
    public func swipeUp(velocity: XCUIGestureVelocity = .default, file: StaticString = #filePath, line: UInt = #line) -> BaseElement {
        XCTContext.runActivity(named: "Свайп вверх: \(element.description)") {
            _ in
            element.swipeUp(velocity: velocity)
        }
        return self
    }

    /// Свайп вниз.
    @discardableResult
    public func swipeDown(velocity: XCUIGestureVelocity = .default, file: StaticString = #filePath, line: UInt = #line) -> BaseElement {
        XCTContext.runActivity(named: "Свайп вниз: \(element.description)") {
            _ in
            element.swipeDown(velocity: velocity)
        }
        return self
    }

    /// Свайп влево.
    @discardableResult
    public func swipeLeft(velocity: XCUIGestureVelocity = .default, file: StaticString = #filePath, line: UInt = #line) -> BaseElement {
        XCTContext.runActivity(named: "Свайп влево: \(element.description)") {
            _ in
            element.swipeLeft(velocity: velocity)
        }
        return self
    }

    /// Свайп вправо.
    @discardableResult
    public func swipeRight(velocity: XCUIGestureVelocity = .default, file: StaticString = #filePath, line: UInt = #line) -> BaseElement {
        XCTContext.runActivity(named: "Свайп вправо: \(element.description)") {
            _ in
            element.swipeRight(velocity: velocity)
        }
        return self
    }

    // MARK: - Scroll

    /// Скролл к элементу.
    @discardableResult
    public func scroll(to element: XCUIElement, file: StaticString = #filePath, line: UInt = #line) -> BaseElement {
        XCTContext.runActivity(named: "Скролл к элементу") {
            _ in
            self.element.scrollToElement(element)
        }
        return self
    }

    /// Скролл вверх.
    @discardableResult
    public func scrollUp(file: StaticString = #filePath, line: UInt = #line) -> BaseElement {
        XCTContext.runActivity(named: "Скролл вверх: \(element.description)") {
            _ in
            element.scrollViews.firstElement.swipeUp()
        }
        return self
    }

    /// Скролл вниз.
    @discardableResult
    public func scrollDown(file: StaticString = #filePath, line: UInt = #line) -> BaseElement {
        XCTContext.runActivity(named: "Скролл вниз: \(element.description)") {
            _ in
            element.scrollViews.firstElement.swipeDown()
        }
        return self
    }

    // MARK: - Coordinate

    /// Получить координату для взаимодействия.
    public func coordinate(file: StaticString = #filePath, line: UInt = #line) -> XCUICoordinate {
        XCTContext.runActivity(named: "Получение координаты: \(element.description)") {
            _ in
            element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        }
    }

    // MARK: - Проверки

    /// Проверка существования элемента.
    @discardableResult
    public func check(exists: Bool, timeout: TimeInterval = defaultTimeout, file: StaticString = #filePath, line: UInt = #line) -> BaseElement {
        XCTContext.runActivity(named: "Проверка \(exists ? "наличия" : "отсутствия") элемента: \(element.description)") { _ in
            if !exists ? element.waitForExistence(timeout: timeout): !element.exists {
                XCTFail("Ошибка проверки: элемент \(exists ? "не найден" : "все еще существует")", file: file, line: line)
            }
        }
        return self
    }

    /// Проверка label элемента.
    @discardableResult
    public func check(label: String, file: StaticString = #filePath, line: UInt = #line) -> BaseElement {
        XCTContext.runActivity(named: "Проверка label: \(label)") {
            _ in
            XCTAssertEqual(element.label, label, file: file, line: line)
        }
        return self
    }

    /// Проверка value элемента.
    @discardableResult
    public func check(value: String, file: StaticString = #filePath, line: UInt = #line) -> BaseElement {
        XCTContext.runActivity(named: "Проверка value: \(value)") {
            _ in
            XCTAssertEqual(element.value as ?String, value, file: file, line: line)
        }
        return self
    }

    /// Проверка enabled состояния.
    @discardableResult
    public func check(enabled: Bool, file: StaticString = #filePath, line: UInt = #line) -> BaseElement {
        XCTContext.runActivity(named: "Проверка enabled: \(enabled)") {
            _ in
            XCTAssertEqual(element.isEnabled, enabled, file: file, line: line)
        }
        return self
    }

    /// Проверка selected состояния.
    @discardableResult
    public func check(selected: Bool, file: StaticString = #filePath, line: UInt = #line) -> BaseElement {
        XCTContext.runActivity(named: "Проверка selected: \(selected)") {
            _ in
            XCTAssertEqual(element.isSelected, selected, file: file, line: line)
        }
        return self
    }

    /// Проверка title элемента.
    @discardableResult
    public func check(title: String, file: StaticString = #filePath, line: UInt = #line) -> BaseElement {
        XCTContext.runActivity(named: "Проверка title: \(title)") {
            _ in
            XCTAssertEqual(element.title, title, file: file, line: line)
        }
        return self
    }

    /// Проверка placeholder.
    @discardableResult
    public func check(placeholder: String, file: StaticString = #filePath, line: UInt = #line) -> BaseElement {
        XCTContext.runActivity(named: "Проверка placeholder: \(placeholder)") {
            _ in
            let placeholderValue = element.placeholderValue ?? ""
            XCTAssertEqual(placeholderValue, placeholder, file: file, line: line)
        }
        return self
    }

    // MARK: - Contains

    /// Проверка что label содержит текст.
    @discardableResult
    public func contains(label: String, file: StaticString = #filePath, line: UInt = #line) -> BaseElement {
        XCTContext.runActivity(named: "Проверка label содержит: \(label)") {
            _ in
            XCTAssertTrue(element.label.contains(label), file: file, line: line)
        }
        return self
    }

    /// Проверка что value содержит текст.
    @discardableResult
    public func contains(value: String, file: StaticString = #filePath, line: UInt = #line) -> BaseElement {
        XCTContext.runActivity(named: "Проверка value содержит: \(value)") {
            _ in
            let currentValue = element.value as ?String ?? ""
            XCTAssertTrue(currentValue.contains(value), file: file, line: line)
        }
        return self
    }

    /// Проверка что placeholder содержит текст.
    @discardableResult
    public func contains(placeholder: String, file: StaticString = #filePath, line: UInt = #line) -> BaseElement {
        XCTContext.runActivity(named: "Проверка placeholder содержит: \(placeholder)") {
            _ in
            let placeholderValue = element.placeholderValue ?? ""
            XCTAssertTrue(placeholderValue.contains(placeholder), file: file, line: line)
        }
        return self
    }

    /// Проверка что title содержит текст.
    @discardableResult
    public func contains(title: String, file: StaticString = #filePath, line: UInt = #line) -> BaseElement {
        XCTContext.runActivity(named: "Проверка title содержит: \(title)") {
            _ in
            XCTAssertTrue(element.title?._trimmingCharacters(in: .whitespacesAndNewlines).contains(title) ?? false, file: file, line: line)
        }
        return self
    }

    /// Проверка что label содержит любой из указанных текстов.
    @discardableResult
    public func contains(anyOfLabels labels: [String], file: StaticString = #filePath, line: UInt = #line) -> BaseElement {
        XCTContext.runActivity(named: "Проверка label содержит любой из: \(labels)") {
            _ in
            let matches = labels.contains {
                element.label.contains($0)
            }
            XCTAssertTrue(matches, "Label '\(element.label)' не содержит ни одного из: \(labels)", file: file, line: line)
        }
        return self
    }

    // MARK: - Does Not Contain

    /// Проверка что label НЕ содержит текст.
    @discardableResult
    public func doesNotContain(label: String, file: StaticString = #filePath, line: UInt = #line) -> BaseElement {
        XCTContext.runActivity(named: "Проверка label НЕ содержит: \(label)") {
            _ in
            XCTAssertFalse(element.label.contains(label), file: file, line: line)
        }
        return self
    }

    /// Проверка что value НЕ содержит текст.
    @discardableResult
    public func doesNotContain(value: String, file: StaticString = #filePath, line: UInt = #line) -> BaseElement {
        XCTContext.runActivity(named: "Проверка value НЕ содержит: \(value)") {
            _ in
            let currentValue = element.value as ?String ?? ""
            XCTAssertFalse(currentValue.contains(value), file: file, line: line)
        }
        return self
    }

    /// Проверка что placeholder НЕ содержит текст.
    @discardableResult
    public func doesNotContain(placeholder: String, file: StaticString = #filePath, line: UInt = #line) -> BaseElement {
        XCTContext.runActivity(named: "Проверка placeholder НЕ содержит: \(placeholder)") {
            _ in
            let placeholderValue = element.placeholderValue ?? ""
            XCTAssertFalse(placeholderValue.contains(placeholder), file: file, line: line)
        }
        return self
    }

    /// Проверка что title НЕ содержит текст.
    @discardableResult
    public func doesNotContain(title: String, file: StaticString = #filePath, line: UInt = #line) -> BaseElement {
        XCTContext.runActivity(named: "Проверка title НЕ содержит: \(title)") {
            _ in
            XCTAssertFalse(element.title?._trimmingCharacters(in: .whitespacesAndNewlines).contains(title) ?? true, file: file, line: line)
        }
        return self
    }

    // MARK: - Wait

    /// Ожидание элемента с таймаутом.
    @discardableResult
    public func wait(fortimeout: TimeInterval, file: StaticString = #filePath, line: UInt = #line) -> BaseElement {
        XCTContext.runActivity(named: "Ожидание элемента \(timeout)с: \(element.description)") {
            _ in
            if !element.waitForExistence(timeout: timeout) {
                XCTFail("Элемент не появился за \(timeout)с", file: file, line: line)
            }
        }
        return self
    }

    /// Ожидание исчезновения элемента.
    @discardableResult
    public func waitForNotExistence(timeout: TimeInterval = defaultTimeout, file: StaticString = #filePath, line: UInt = #line) -> BaseElement {
        XCTContext.runActivity(named: "Ожидание исчезновения элемента: \(element.description)") {
            _ in
            if element.waitForExistence(timeout: timeout) {
                XCTFail("Элемент не исчез за \(timeout)с", file: file, line: line)
            }
        }
        return self
    }

    /// Ожидание элемента с предикатом.
    @discardableResult
    public func wait(forpredicate: UTPredicates, timeout: TimeInterval = defaultTimeout) -> BaseElement {
        XCTContext.runActivity(named: "Ожидание элемента с предикатом: \(element.description)") {
            _ in
            XCTWaiter().wait(for: XCTNSPredicateExpectation(predicate: predicate.get(), object: self.element), timeout: timeout)
        }
        return self
    }

    // MARK: - Theme

    /// Проверка theme (адаптация под темную/светлую тему).
    @discardableResult
    public func check(theme: String, file: StaticString = #filePath, line: UInt = #line) -> BaseElement {
        XCTContext.runActivity(named: "Проверка theme: \(theme)") {
            _ in
            let currentTraits = element.value as ?String ?? ""
            XCTAssertTrue(currentTraits.contains(theme) || theme.isEmpty, file: file, line: line)
        }
        return self
    }
}
