// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.

import XCTest

@MainActor
open class BaseTestCase: XCTestCase {

    /// UTOutputInterceptor - логирование в файл
    private let outputInterceptor = UTOutputInterceptor()

    override open func setUp() async throws {
        try await super.setUp()

        // Инициализация файлового логирования
        Logger.initializeFileLogger()
        Logger.shouldEnableLogs = shouldEnableLogs

        // Запуск test observer
        testObserver.isEnabled = true

        continueAfterFailure = false

        step("Запуск приложения") {
            // Установка приложения через localServer если доступно
            localServer.installApplication()

            app.launchArguments = ["-ui-tests", "-reset"]
            app.launchEnvironment[LaunchEnv.animations] = "false"
            app.launch()
        }
    }

    override open func tearDown() async throws {
        if let failureCount = testRun?.failureCount, failureCount > 0 {
            step("Сбор данных при падении") {
                // Логирование debugDescription приложения
                Logger.error("Application debugDescription: \(app.debugDescription)")

                // Иерархия элементов
                let hierarchy = XCTAttachment(string: app.debugDescription)
                hierarchy.name = "UI Hierarchy"
                hierarchy.lifetime = .keepAlways
                add(hierarchy)

                // Скриншот
                let screenshot = app.screenshot()
                let attachment = XCTAttachment(screenshot: screenshot)
                attachment.name = "Screenshot on Failure"
                attachment.lifetime = .keepAlways
                add(attachment)

                // Сбор данных через testObserver
                let failureData = testObserver.collectFailureData(for: self)
                Logger.debug("Failure data: \(failureData)")
            }
        }

        // Закрыть файловый логгер
        Logger.closeFileLogger()

        try await super.tearDown()
    }
}

// MARK: - UTOutputInterceptor

/// Перехватчик вывода для логирования в файл
/// Аналог UTOutputInterceptor из tx-mobile
@MainActor
public final class UTOutputInterceptor {

    /// Инициализация перехватчика
    public init() {
        startCapturing()
    }

    /// Начать перехват вывода
    private func startCapturing() {
        // Перенаправление stdout/stderr для записи в файл
        let outputPipe = Pipe()
        let errorPipe = Pipe()

        // Сохраняем оригинальные дескрипторы
        dup2(outputPipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
        dup2(errorPipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO)

        // Читаем из pipes в фоновом режиме
        readFromPipe(outputPipe, isError: false)
        readFromPipe(errorPipe, isError: true)
    }

    private func readFromPipe(_ pipe: Pipe, isError: Bool) {
        let reader = pipe.fileHandleForReading
        reader.readabilityHandler = {
            handle in
            let data = handle.availableData
            if !data.isEmpty {
                let output = String(data: data, encoding: .utf8) ?? ""
                if !output.isEmpty {
                    Logger.info("[\(isError ? "STDERR": "STDOUT")] \(output)")
                    Logger.writeToFile("[\(isError ? "STDERR": "STDOUT")] \(output)")
                }
            }
        }
    }

    /// Остановить перехват.
    public func stopCapturing() {
        // Восстановить оригинальные дескрипторы
    }
}
