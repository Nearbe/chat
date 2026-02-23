// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.

import Foundation
import XCTest

/// Переиспользуемые предикаты для ожидания элементов
public enum Predicates {
    case enabled
    case disabled
    case hittable
    case visible
    case keyboardFocused
    case labelEquals(String)
    case valueEquals(String)

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
