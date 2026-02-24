// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.

import UIKit
import XCTest

/// Типизированный элемент кнопки
@MainActor
public class UTButton: BaseElement {

    /// Инициализация кнопки
    public init(_ element: XCUIElement,
    waitForExistence: Bool = true,
    timeout: TimeInterval = defaultTimeout,
    file: StaticString = #filePath,
    line: UInt = #line) {
        super.init(element, waitForExistence: waitForExistence, timeout: timeout, file: file, line: line)
    }

    /// Нажать на кнопку
    @discardableResult
    public override func tap(file: StaticString = #filePath, line: UInt = #line) -> UTButton {
        super.tap(file: file, line: line)
        return self
    }

    /// Проверить title кнопки
    @discardableResult
    public func check(title: String, file: StaticString = #filePath, line: UInt = #line) -> UTButton {
        XCTContext.runActivity(named: "Проверка title кнопки: \(title)") {
            _ in
            XCTAssertEqual(element.title, title, file: file, line: line)
        }
        return self
    }

    /// Проверить что title содержит текст
    @discardableResult
    public func contains(title: String, file: StaticString = #filePath, line: UInt = #line) -> UTButton {
        XCTContext.runActivity(named: "Проверка title содержит: \(title)") {
            _ in
            let currentTitle = element.title ?? ""
            XCTAssertTrue(currentTitle.contains(title), file: file, line: line)
        }
        return self
    }

    /// Проверить что title НЕ содержит текст
    @discardableResult
    public func doesNotContain(title: String, file: StaticString = #filePath, line: UInt = #line) -> UTButton {
        XCTContext.runActivity(named: "Проверка title НЕ содержит: \(title)") {
            _ in
            let currentTitle = element.title ?? ""
            XCTAssertFalse(currentTitle.contains(title), file: file, line: line)
        }
        return self
    }
}

/// Типизированный элемент ввода текста
@MainActor
public class UTInput: BaseElement {

    /// Инициализация поля ввода
    public init(_ element: XCUIElement,
    waitForExistence: Bool = true,
    timeout: TimeInterval = defaultTimeout,
    file: StaticString = #filePath,
    line: UInt = #line) {
        super.init(element, waitForExistence: waitForExistence, timeout: timeout, file: file, line: line)
    }

    /// Ввести текст
    @discardableResult
    public override func type(_ text: String, file: StaticString = #filePath, line: UInt = #line) -> UTInput {
        super.type(text, file: file, line: line)
        return self
    }

    /// Очистить поле ввода
    @discardableResult
    public override func clear(file: StaticString = #filePath, line: UInt = #line) -> UTInput {
        super.clear(file: file, line: line)
        return self
    }

    /// Вставить текст
    @discardableResult
    public override func paste(_ text: String, file: StaticString = #filePath, line: UInt = #line) -> UTInput {
        super.paste(text, file: file, line: line)
        return self
    }

    /// Проверить value
    @discardableResult
    public override func check(value: String, file: StaticString = #filePath, line: UInt = #line) -> UTInput {
        super.check(value: value, file: file, line: line)
        return self
    }

    /// Проверить placeholder
    @discardableResult
    public override func check(placeholder: String, file: StaticString = #filePath, line: UInt = #line) -> UTInput {
        super.check(placeholder: placeholder, file: file, line: line)
        return self
    }

    /// Проверить что value содержит текст
    @discardableResult
    public override func contains(value: String, file: StaticString = #filePath, line: UInt = #line) -> UTInput {
        super.contains(value: value, file: file, line: line)
        return self
    }
}

/// Типизированный защищенный элемент ввода (пароль)
@MainActor
public class UTSecureInput: UTInput {

    /// Инициализация защищенного поля ввода
    public init(_ element: XCUIElement,
    waitForExistence: Bool = true,
    timeout: TimeInterval = defaultTimeout,
    file: StaticString = #filePath,
    line: UInt = #line) {
        super.init(element, waitForExistence: waitForExistence, timeout: timeout, file: file, line: line)
    }

    /// Ввести пароль
    @discardableResult
    public func enterPassword(_ password: String, file: StaticString = #filePath, line: UInt = #line) -> UTSecureInput {
        XCTContext.runActivity(named: "Ввод пароля в защищенное поле") {
            _ in
            element.tap()
            element.typeText(password)
        }
        return self
    }

    /// Переключить видимость пароля
    @discardableResult
    public func toggleVisibility(file: StaticString = #filePath, line: UInt = #line) -> UTSecureInput {
        XCTContext.runActivity(named: "Переключение видимости пароля") {
            _ in
            element.buttons["Показать пароль"].tap()
        }
        return self
    }
}

/// Типизированный TextField элемент
@MainActor
public class UTTextField: UTInput {

    /// Инициализация TextField
    public init(_ element: XCUIElement,
    waitForExistence: Bool = true,
    timeout: TimeInterval = defaultTimeout,
    file: StaticString = #filePath,
    line: UInt = #line) {
        super.init(element, waitForExistence: waitForExistence, timeout: timeout, file: file, line: line)
    }

    /// Проверить что поле в фокусе
    @discardableResult
    public func checkFocused(file: StaticString = #filePath, line: UInt = #line) -> UTTextField {
        XCTContext.runActivity(named: "Проверка фокуса на TextField") {
            _ in
            XCTAssertTrue(element.hasKeyboardFocus, file: file, line: line)
        }
        return self
    }
}

/// Универсальный типизированный элемент с type-specific методами
@MainActor
public class UTElement: BaseElement {

    /// Тип элемента
    public enum ElementType {
        case button
        case textField
        case textView
        case staticText
        case image
        case cell
        case navigationBar
        case header
        case other
    }

    /// Определить тип элемента
    public let elementType: ElementType

    /// Инициализация
    public init(_ element: XCUIElement,
    type: ElementType = .other,
    waitForExistence: Bool = true,
    timeout: TimeInterval = defaultTimeout,
    file: StaticString = #filePath,
    line: UInt = #line) {
        self.elementType = type
        super.init(element, waitForExistence: waitForExistence, timeout: timeout, file: file, line: line)
    }

    /// Методы для кнопок
    public var asButton: UTButton {
        UTButton(element, timeout: elementTimeout)
    }

    /// Методы для полей ввода
    public var asInput: UTInput {
        UTInput(element, timeout: elementTimeout)
    }

    /// Методы для защищенных полей
    public var asSecureInput: UTSecureInput {
        UTSecureInput(element, timeout: elementTimeout)
    }

    /// Методы для TextField
    public var asTextField: UTTextField {
        UTTextField(element, timeout: elementTimeout)
    }
}

/// NavigationBar элемент
@MainActor
public class UTNavigationBar: BaseElement {

    /// Заголовок navigation bar
    public var title: String? {
        element.staticTexts.firstMatch.label
    }

    /// Кнопка назад
    public var backButton: UTButton {
        UTButton(element.buttons.firstMatch)
    }

    /// Инициализация
    public init(_ element: XCUIElement,
    waitForExistence: Bool = true,
    timeout: TimeInterval = defaultTimeout,
    file: StaticString = #filePath,
    line: UInt = #line) {
        super.init(element, waitForExistence: waitForExistence, timeout: timeout, file: file, line: line)
    }

    /// Нажать назад
    @discardableResult
    public func tapBack(file: StaticString = #filePath, line: UInt = #line) -> UTNavigationBar {
        XCTContext.runActivity(named: "Нажатие кнопки назад") {
            _ in
            backButton.tap()
        }
        return self
    }

    /// Проверить title
    @discardableResult
    public func check(title: String, file: StaticString = #filePath, line: UInt = #line) -> UTNavigationBar {
        XCTContext.runActivity(named: "Проверка title navigation bar: \(title)") {
            _ in
            XCTAssertEqual(self.title, title, file: file, line: line)
        }
        return self
    }
}

/// Header элемент
@MainActor
public class UTHeader: BaseElement {

    /// Текст заголовка
    public var text: String? {
        element.staticTexts.firstMatch.label
    }

    /// Инициализация
    public init(_ element: XCUIElement,
    waitForExistence: Bool = true,
    timeout: TimeInterval = defaultTimeout,
    file: StaticString = #filePath,
    line: UInt = #line) {
        super.init(element, waitForExistence: waitForExistence, timeout: timeout, file: file, line: line)
    }

    /// Проверить text
    @discardableResult
    public func check(text: String, file: StaticString = #filePath, line: UInt = #line) -> UTHeader {
        XCTContext.runActivity(named: "Проверка text header: \(text)") {
            _ in
            XCTAssertEqual(self.text, text, file: file, line: line)
        }
        return self
    }
}
