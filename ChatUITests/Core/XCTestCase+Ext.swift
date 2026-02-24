// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.

import Foundation
import XCTest

/// Расширения для XCTestCase - добавляют DSL для тестов
@MainActor
public extension XCTestCase {

    /// Выполнить шаг теста с именем
    /// - Parameters:
    ///   - name: Название шага
    ///   - step: Замыкание с логикой шага
    func step(_ name: String, step: () -> Void) {
        XCTContext.runActivity(named: name) {
            _ in
            step()
        }
    }

    /// Добавить связь с задачей (TMS)
    /// - Parameter dict: Словарь с ссылками
    func links(_ dict: [String: String]) {
        dict.forEach {
            name, value in
            XCTContext.runActivity(named: "allure.link.\(name)[tms]:\(value)", block: {
                _ in
            })
        }
    }

    /// Добавить параметры теста
    /// - Parameter dict: Словарь параметров
    func parameters(_ dict: [String: String]) {
        dict.forEach {
            name, value in
            XCTContext.runActivity(named: "allure.parameters.\(name):\(value)", block: {
                _ in
            })
        }
    }

    /// Добавить метки для Allure
    /// - Parameter dict: Словарь меток
    func label(_ dict: [String: String]) {
        dict.forEach {
            name, value in
            XCTContext.runActivity(named: "allure.label.\(name):\(value)", block: {
                _ in
            })
        }
    }

    /// Добавить описание для Allure
    /// - Parameter dict: Словарь описаний
    func description(_ dict: [String: String]) {
        dict.forEach {
            name, value in
            XCTContext.runActivity(named: "allure.description:\(name): \(value)", block: {
                _ in
            })
        }
    }

    /// Добавить ссылку на задачу
    /// - Parameter dict: Словарь с ссылками на задачи
    func issue(_ dict: [String: String]) {
        dict.forEach {
            name, value in
            XCTContext.runActivity(named: "allure.link.\(name)[issue]:\(value)", block: {
                _ in
            })
        }
    }

    /// Метаданные теста для Allure
    struct MetaData {
        /// Название теста
        public let name: String
        /// Название набора тестов
        public let suite: String
        /// Тип тестов
        public let type: String
        /// Уникальный ID
        public let id: String
        /// ID теста в TMS
        public let testKeyID: String

        /// Инициализация метаданных
        public init(name: String, suite: String, testKeyID: String) {
            self.name = name
            self.suite = suite
            self.type = "iOS E2E Tests"
            self.id = "\(type).\(suite).\(name)"
            self.testKeyID = testKeyID
        }
    }

    /// Получить метаданные теста из файла
    /// - Parameters:
    ///   - file: Путь к файлу теста
    ///   - testKeyID: ID теста в TMS системе
    /// - Returns: Метаданные теста
    func metaData(from file: String = #file, _ testKeyID: String) -> MetaData {
        let url = URL(fileURLWithPath: (file as NSString).deletingPathExtension)

        let name = url.lastPathComponent.replacingOccurrences(of: "UITest", with: "")

        let suite = url.deletingLastPathComponent().lastPathComponent

        let metaData = MetaData(name: name, suite: suite, testKeyID: testKeyID)

        let labels = [
            "type": metaData.type,
            "suite": metaData.suite,
            "name": metaData.name,
            "id": metaData.id,
            "testKeyID": metaData.testKeyID,
            "language": "Swift",
            "framework": "XCUITest"
        ]

        label(labels)
        return metaData
    }
}
