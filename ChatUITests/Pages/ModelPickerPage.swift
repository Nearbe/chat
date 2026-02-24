// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.

import XCTest
import SwiftUI

/// Объект страницы для экрана выбора модели
@MainActor
final class ModelPickerPage {

    // MARK: - Элементы

    var title: XCUIElement {
        app.staticTexts["model_picker_title"]
    }

    var noModelsText: XCUIElement {
        app.staticTexts["no_models_available"]
    }

    var modelCells: XCUIElementQuery {
        app.cells
    }

    // MARK: - Действия

    @discardableResult
    func selectModel(at index: Int) -> ModelPickerPage {
        XCTContext.runActivity(named: "Выбор модели #\(index)") {
            _ in
            app.cells.element(boundBy: index).tap()
        }
        return self
    }

    @discardableResult
    func selectModel(named name: String) -> ModelPickerPage {
        XCTContext.runActivity(named: "Выбор модели: \(name)") {
            _ in
            app.staticTexts[name].tap()
        }
        return self
    }

    @discardableResult
    func downloadModel(at index: Int) -> ModelPickerPage {
        XCTContext.runActivity(named: "Скачивание модели #\(index)") {
            _ in
            let cell = app.cells.element(boundBy: index)
            // Поиск кнопки скачивания в ячейке
            if cell.buttons["download_button"].exists {
                cell.buttons["download_button"].tap()
            } else if cell.buttons["Скачать"].exists {
                cell.buttons["Скачать"].tap()
            }
        }
        return self
    }

    @discardableResult
    func loadModel(at index: Int) -> ModelPickerPage {
        XCTContext.runActivity(named: "Загрузка модели #\(index)") {
            _ in
            let cell = app.cells.element(boundBy: index)
            // Поиск кнопки загрузки в ячейке
            if cell.buttons["load_button"].exists {
                cell.buttons["load_button"].tap()
            } else if cell.buttons["Загрузить"].exists {
                cell.buttons["Загрузить"].tap()
            } else {
                // Если кнопки нет, просто выбираем модель
                cell.tap()
            }
        }
        return self
    }

    @discardableResult
    func close() -> ModelPickerPage {
        app.buttons["close"].tap()
        return self
    }

    // MARK: - Проверки

    func checkNoModelsVisible() {
        XCTAssertTrue(noModelsText.exists)
    }

    func checkModelCount(atLeast count: Int) {
        XCTAssertGreaterThanOrEqual(modelCells.count, count)
    }

    func checkModelLoaded(name: String) {
        // Проверка что модель загружена
        XCTAssertTrue(app.staticTexts[name].exists)
    }
}
