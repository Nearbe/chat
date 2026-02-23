// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.

import XCTest

/// Расширение BaseElement с шорткатами для часто используемых запросов
@MainActor
public extension BaseElement {

    // MARK: - Shorthand queries

    var buttons: XCUIElementQuery { element.buttons }

    var staticTexts: XCUIElementQuery { element.staticTexts }

    var textFields: XCUIElementQuery { element.textFields }

    var textViews: XCUIElementQuery { element.textViews }

    var images: XCUIElementQuery { element.images }

    var tables: XCUIElementQuery { element.tables }

    var cells: XCUIElementQuery { element.cells }

    var scrollViews: XCUIElementQuery { element.scrollViews }

    var collectionViews: XCUIElementQuery { element.collectionViews }

    var navigationBars: XCUIElementQuery { element.navigationBars }

    var tabBars: XCUIElementQuery { element.tabBars }

    var alerts: XCUIElementQuery { element.alerts }

    var sheets: XCUIElementQuery { element.sheets }

    var switches: XCUIElementQuery { element.switches }

    var sliders: XCUIElementQuery { element.sliders }

    var segmentedControls: XCUIElementQuery { element.segmentedControls }

    var pickers: XCUIElementQuery { element.pickers }

    var datePickers: XCUIElementQuery { element.datePickers }
}
