// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.

import XCTest

/// Элемент кнопки
@MainActor
public final class UTButton: BaseElement {

    public var image: BaseElement { BaseElement(element.images["Image"]) }
    public var text: BaseElement { BaseElement(element.staticTexts["Text"]) }
    public var progressView: BaseElement { BaseElement(element.staticTexts["ProgressView"]) }

    public init(_ element: XCUIElement, waitForExistence: Bool = true) {
        super.init(element, waitForExistence: waitForExistence)
    }

    public convenience init(identifier: String, waitForExistence: Bool = true) {
        self.init(app.buttons[identifier], waitForExistence: waitForExistence)
    }
}
