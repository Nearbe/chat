// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.

import Foundation
import XCTest

/// Утилита для удалённого управления симулятором через Python HTTP сервер
/// Позволяет устанавливать и удалять приложения на удалённых симуляторах
/// при параллельном запуске тестов
///
/// Требует запущенного Python сервера: `python AutotestsLocalWebServer.py`
@MainActor
final class LocalServer {

    // MARK: - Свойства

    private let httpClient = HttpClient()
    private let serverPort: Int

    /// UDID симулятора
    private var udid: String {
        getEnvironmentVariable("SIMULATOR_UDID")
    }

    /// Включена ли параллелизация
    private var isParallelizationEnabled: String {
        getEnvironmentVariable("PARALLELIZATION_ENABLED", swallowAssert: true)
    }

    /// Путь к приложению
    private var appPath: String {
        getEnvironmentVariable("APP_PATH", swallowAssert: true)
    }

    // MARK: - Инициализация

    /// Создать LocalServer
    /// - Parameter port: Порт Python сервера (по умолчанию 63281)
    init(port: Int = 63281) {
        self.serverPort = port
    }

    // MARK: - Публичные методы

    /// Удалить приложение с симулятора
    func deleteApplication(bundleIdentifier: String) {
        let expectation = XCTestExpectation(description: "Delete Application")
        let setTestingDevices = "--set testing "
        let command = "xcrun simctl \(isParallelizationEnabled == "true" ? "\(setTestingDevices)" : "")uninstall \(udid) \(bundleIdentifier)"
        execute(command: command, fulfill: expectation)
        XCTWaiter().wait(for: [expectation], timeout: 20)
    }

    /// Установить приложение на симулятор
    func installApplication() {
        guard !appPath.isEmpty else {
            Logger.warning("APP_PATH не задан, пропуск установки")
            return
        }
        let expectation = XCTestExpectation(description: "Install Application")
        let setTestingDevices = "--set testing "
        let command = "xcrun simctl \(isParallelizationEnabled == "true" ? "\(setTestingDevices)" : "")install \(udid) \(appPath)"
        execute(command: command, fulfill: expectation)
        XCTWaiter().wait(for: [expectation], timeout: 20)
    }

    /// Выполнить произвольную команду на сервере
    /// - Parameters:
    ///   - command: Команда для выполнения
    ///   - expectation: Ожидание для выполнения после команды
    func execute(command: String, fulfill expectation: XCTestExpectation) {
        let url = URL(string: "http://0.0.0.0:\(serverPort)")!

        let request = httpClient.setup(
            request: url,
            method: "POST",
            body: command.data(using: .utf8)
        )

        httpClient.send(request: request) { error, success in
            if let error = error {
                Logger.error(error.localizedDescription)
            }
            if let success = success {
                Logger.info(String(decoding: success, as: UTF8.self))
            }
            expectation.fulfill()
        }
    }
}

/// Глобальный экземпляр для управления локальным сервером
public let localServer = LocalServer()
