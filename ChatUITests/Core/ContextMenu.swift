// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.

import XCTest

/// Хелпер для работы с контекстным меню (копировать, вставить, выбрать все)
/// Аналог UTContextMenu из tx-mobile
@MainActor
public final class ContextMenu {

    // MARK: - Элементы меню

    /// Кнопка "Скопировать"
    public var copyButton: BaseElement {
        BaseElement(app.menuItems["Скопировать"], waitForExistence: false)
    }

    /// Кнопка "Выбрать все"
    public var selectAllButton: BaseElement {
        BaseElement(app.menuItems["Выбрать все"])
    }

    /// Кнопка "Вставить"
    public var pasteButton: BaseElement {
        BaseElement(app.menuItems["Вставить"])
    }

    /// Кнопка "Вырезать"
    public var cutButton: BaseElement {
        BaseElement(app.menuItems["Вырезать"])
    }

    /// Кнопка "Удалить"
    public var deleteButton: BaseElement {
        BaseElement(app.menuItems["Удалить"])
    }

    /// Кнопка "Готово"
    public var doneButton: BaseElement {
        BaseElement(app.menuItems["Готово"])
    }
}

// MARK: - Глобальный экземпляр

/// Глобальный доступ к контекстному меню
public var contextMenu: ContextMenu {
    ContextMenu()
}
