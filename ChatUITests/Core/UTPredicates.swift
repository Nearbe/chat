// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.

import Foundation

/// Предикаты для ожидания элементов.
/// Аналог UTPredicates из tx-mobile.
public enum UTPredicates {
    /// Элемент включен.
    case enabled
    /// Элемент выключен.
    case disabled
    /// Элемент доступен для тапа.
    case hittable
    /// Элемент видим.
    case visible
    /// Элемент имеет фокус клавиатуры.
    case keyboardFocused
    /// Label элемента равен указанному значению.
    case labelEquals(String)
    /// Value элемента равен указанному значению.
    case valueEquals(String)

    /// Получить NSPredicate для использования с XCTWaiter.
    public func get() -> NSPredicate {
        switch self {
        case .enabled:
            return NSPredicate(format: "enabled == true")
        case .disabled:
            return NSPredicate(format: "enabled == false")
        case .hittable:
            return NSPredicate(format: "hittable == true")
        case .visible:
            return NSPredicate(format: "enabled == true && hittable == true")
        case .keyboardFocused:
            return NSPredicate(format: "hasKeyboardFocus == true")
        case .labelEquals(let label):
            return NSPredicate(format: "label == %@", label)
        case .valueEquals(let value):
            return NSPredicate(format: "value == %@", value)
        }
    }
}
