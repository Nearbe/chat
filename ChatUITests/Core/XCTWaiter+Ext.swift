// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.

import Foundation
import XCTest

/// Расширения для XCTWaiter с улучшенной обработкой ошибок
/// Аналог XCTWaiter+Ext из tx-mobile
public extension XCTWaiter {

    /// Ожидание одной expectation с автоматической обработкой ошибок
    /// - Parameters:
    ///   - expectation: Ожидание, которое нужно дождаться
    ///   - seconds: Таймаут в секундах
    ///   - file: Файл, откуда вызван метод
    ///   - line: Строка, откуда вызван метод
    func wait(forexpectation: XCTestExpectation,
    timeout seconds: TimeInterval = networkTimeout,
    file: StaticString = #filePath,
    line: UInt = #line) {
        get(result: wait(for: [expectation], timeout: seconds), file: file, line: line)
    }

    /// Ожидание массива expectations с автоматической обработкой ошибок
    /// - Parameters:
    ///   - expectations: Массив ожиданий
    ///   - seconds: Таймаут в секундах
    ///   - file: Файл, откуда вызван метод
    ///   - line: Строка, откуда вызван метод
    func wait(forexpectations: [XCTestExpectation],
    timeout seconds: TimeInterval = networkTimeout,
    file: StaticString = #filePath,
    line: UInt = #line) {
        get(result: wait(for: expectations, timeout: seconds), file: file, line: line)
    }

    /// Обработка результата ожидания с генерацией понятных сообщений об ошибках
    /// - Parameters:
    ///   - result: Результат ожидания
    ///   - file: Файл, откуда вызван метод
    ///   - line: Строка, откуда вызван метод
    private func get(result: Result,
    file: StaticString = #filePath,
    line: UInt = #line) {
        var message = ""
        switch result {
        case .completed:
            return
        case .timedOut:
            message = "Условие не было выполнено в течение отведенного времени"
        case .interrupted:
            message = "Ожидание было прервано до выполнения условий или истечения таймаута"
        case .incorrectOrder:
            message = "Ожидания не были выполнены в требуемом порядке"
        case .invertedFulfillment:
            message = "Инвертированное ожидание было выполнено"
        @unknown default:
            return
        }
        if !message.isEmpty {
            XCTFail(message, file: file, line: line)
        }
    }
}
