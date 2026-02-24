// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.

import XCTest

/// Расширение BaseElement с шорткатами для часто используемых запросов
@MainActor
public extension BaseElement {

    // MARK: - Shorthand queries

    /// Кнопки
    var buttons: XCUIElementQuery { element.buttons }

    /// Текстовые элементы
    var staticTexts: XCUIElementQuery { element.staticTexts }

    /// Текстовые поля
    var textFields: XCUIElementQuery { element.textFields }

    /// Текстовые представления
    var textViews: XCUIElementQuery { element.textViews }

    /// Изображения
    var images: XCUIElementQuery { element.images }

    /// Таблицы
    var tables: XCUIElementQuery { element.tables }

    /// Ячейки
    var cells: XCUIElementQuery { element.cells }

    /// Скролл-вью
    var scrollViews: XCUIElementQuery { element.scrollViews }

    /// Коллекции
    var collectionViews: XCUIElementQuery { element.collectionViews }

    /// Навигационные панели
    var navigationBars: XCUIElementQuery { element.navigationBars }

    /// Панели вкладок
    var tabBars: XCUIElementQuery { element.tabBars }

    /// Оповещения
    var alerts: XCUIElementQuery { element.alerts }

    /// Листы
    var sheets: XCUIElementQuery { element.sheets }

    /// Переключатели
    var switches: XCUIElementQuery { element.switches }

    /// Слайдеры
    var sliders: XCUIElementQuery { element.sliders }

    /// Сегментированные элементы управления
    var segmentedControls: XCUIElementQuery { element.segmentedControls }

    /// Пикеры
    var pickers: XCUIElementQuery { element.pickers }

    /// Пикеры даты
    var datePickers: XCUIElementQuery { element.datePickers }
}
