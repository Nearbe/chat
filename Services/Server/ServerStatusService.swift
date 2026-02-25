// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.

import Foundation
import Factory

// MARK: - Статус сервера (Server Status)

/// Перечисление состояний LM Studio сервера
/// Используется для отображения статуса подключения в UI
enum ServerStatus: Equatable, Sendable {
    /// Статус неизвестен (сервер ещё не проверялся)
    case unknown

    /// Сервер запускается
    case starting

    /// Сервер работает и доступен
    case running

    /// Сервер останавливается
    case stopping

    /// Сервер недоступен (нет ответа или ошибка)
    case unavailable
}

// MARK: - Ошибки сервера (Server Errors)

/// Кастомные ошибки для операций с LM Studio сервером
enum ServerError: LocalizedError {
    /// Ошибка запуска сервера через SSH
    case serverStartFailed(String)

    /// Ошибка остановки сервера через SSH
    case serverStopFailed(String)

    /// SSH хост не настроен
    case sshHostNotConfigured

    var errorDescription: String? {
        switch self {
        case .serverStartFailed(let message):
            return "Не удалось запустить сервер: \(message)"
        case .serverStopFailed(let message):
            return "Не удалось остановить сервер: \(message)"
        case .sshHostNotConfigured:
            return "SSH хост не настроен в приложении"
        }
    }
}

// MARK: - Протокол сервиса статуса сервера

/// Протокол для мониторинга и управления LM Studio сервером
/// Позволяет тестировать сервис через mock реализации
@MainActor
protocol ServerStatusServicing: AnyObject {
    /// Проверить статус сервера
    /// - Returns: Текущий статус сервера
    /// - Throws: Ошибки сети или сервера
    func checkStatus() async throws -> ServerStatus

    /// Запустить сервер через SSH
    /// - Throws: ServerError при ошибках запуска
    func startServer() async throws

    /// Остановить сервер через SSH
    /// - Throws: ServerError при ошибках остановки
    func stopServer() async throws
}

// MARK: - Сервис мониторинга и управления сервером

/// Сервис для мониторинга состояния LM Studio сервера
/// и удалённого управления через SSH
///
/// Использует:
/// - HTTPClient для ping проверки доступности
/// - Process для выполнения SSH команд
/// - AppConfig для получения настроек подключения
@MainActor
final class ServerStatusService: ServerStatusServicing {

    // MARK: - Зависимости (Dependencies)

    /// HTTP клиент для сетевых запросов
    @Injected(\.httpClient) private var httpClient: HTTPClient

    // MARK: - Константы (Constants)

    /// Таймаут для ping запроса в секундах
    private let pingTimeout: TimeInterval = 5.0

    /// Эндпоинт для проверки доступных моделей
    private let modelsEndpoint = "/api/v1/models"

    // MARK: - Публичные методы (Public Methods)

    /// Проверить статус LM Studio сервера
    /// Выполняет GET запрос к /api/v1/models для проверки доступности
    ///
    /// - Returns: Текущий статус сервера
    /// - Throws:
    ///   - NetworkError.invalidURL - если baseURL не настроен
    ///   - NetworkError.networkError - при ошибке сети
    ///   - Другие ошибки HTTP при некорректных статус-кодах
    func checkStatus() async throws -> ServerStatus {
        let config = AppConfig.shared

        guard !config.baseURL.isEmpty else {
            return .unavailable
        }

        guard let modelsURL = config.modelsURL else {
            return .unavailable
        }

        do {
            let (_, response) = try await withTimeout(seconds: pingTimeout) {
                try await self.httpClient.get(url: modelsURL)
            }

            if let httpResponse = response as ?HTTPURLResponse,
            (200 ... 299).contains(httpResponse.statusCode) {
                return .running
            }

            return .unavailable
        } catch is TimeoutError {
            return .unavailable
        } catch let error as NetworkError {
            switch error {
            case .unauthorized, .forbidden:
                return .running
            default:
                return .unavailable
            }
        } catch {
            return .unavailable
        }
    }

    /// Запустить LM Studio сервер через SSH
    /// Выполняет команду `lms server start` на удалённом хосте
    ///
    /// - Throws:
    ///   - ServerError.sshHostNotConfigured - если SSH хост не настроен
    ///   - ServerError.serverStartFailed - при ошибке выполнения SSH команды
    func startServer() async throws {
        try await executeSSHCommand(command: "lms server start", failureError: ServerError.serverStartFailed)
    }

    /// Остановить LM Studio сервер через SSH
    /// Выполняет команду `lms server stop` на удалённом хосте
    ///
    /// - Throws:
    ///   - ServerError.sshHostNotConfigured - если SSH хост не настроен
    ///   - ServerError.serverStopFailed - при ошибке выполнения SSH команды
    func stopServer() async throws {
        try await executeSSHCommand(command: "lms server stop", failureError: ServerError.serverStopFailed)
    }

    // MARK: - Приватные методы (Private Methods)

    /// Выполнить SSH команду на удалённом хосте
    /// - Parameters:
    ///   - command: Команда для выполнения на удалённом Mac
    ///   - failureError: Тип ошибки при неудаче
    /// - Throws: ServerError при ошибках подключения или выполнения
    private func executeSSHCommand(command: String,
    failureError: (String) -> ServerError) async throws {
        let config = AppConfig.shared

        guard !config.sshHost.isEmpty else {
            throw ServerError.sshHostNotConfigured
        }

        let portFlag = config.sshPort == 22 ? "": "-p \(config.sshPort)"
        let sshCommand = "ssh \(portFlag) \(config.sshHost) '\(command)'"

        try await runShellCommand(sshCommand, failureError: failureError)
    }

    /// Выполнить shell команду
    /// - Parameters:
    ///   - command: Команда для выполнения
    ///   - failureError: Тип ошибки при неудаче
    /// - Throws: ServerError при ненулевом коде завершения
    private func runShellCommand(_ command: String,
    failureError: (String) -> ServerError) async throws {
        let process = Process()
        let pipe = Pipe()

        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["-c", command]
        process.standardOutput = pipe
        process.standardError = pipe

        try process.run()
        process.waitUntilExit()

        if process.terminationStatus != 0 {
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw failureError(output)
        }
    }

    /// Выполнить асинхронную операцию с таймаутом
    /// - Parameters:
    ///   - seconds: Таймаут в секундах
    ///   - operation: Асинхронная операция
    /// - Returns: Результат операции
    /// - Throws: TimeoutError при превышении таймаута
    private func withTimeout<T>(seconds: TimeInterval,
    operation: @escaping () async throws -> T) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) {
            group in
            group.addTask {
                try await operation()
            }

            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw TimeoutError()
            }

            let result = try await group.next() !
            group.cancelAll()
            return result
        }
    }
}

// MARK: - Ошибка таймаута (Timeout Error)

/// Ошибка, возникающая при превышении времени ожидания
private struct TimeoutError: Error, LocalizedError {
    var errorDescription: String? {
        "Превышен таймаут"
    }
}

// MARK: - Регистрация в Container

extension Container {
    /// HTTP клиент для сетевых запросов
    var httpClient: Factory<HTTPClient> {
        Factory(self) {
            HTTPClient()
        }
    }
}
