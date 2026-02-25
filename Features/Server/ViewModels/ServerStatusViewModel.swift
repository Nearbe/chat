// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.

import SwiftUI
import Factory

// MARK: - ViewModel статуса сервера

/// ViewModel для мониторинга и управления LM Studio сервером
/// Использует polling для проверки статуса каждые 10 секунд
@MainActor
@Observable
final class ServerStatusViewModel {

    // MARK: - Состояние (State)

    /// Текущий статус сервера
    var status: ServerStatus = .unknown

    /// Флаг загрузки при выполнении команд
    var isLoading: Bool = false

    /// Сообщение об ошибке для пользователя
    var errorMessage: String?

    // MARK: - Зависимости (Dependencies)

    /// Сервис для работы с сервером
    @Injected(\.serverStatusService) private var serverStatusService: ServerStatusService

    // MARK: - Приватные свойства (Private Properties)

    /// Task для polling
    private var pollingTask: Task<Void, Never>?

    /// Интервал polling в секундах
    private let pollingIntervalSeconds: UInt64 = 10

    // MARK: - Инициализация (Init)

    init() {
    }

    deinit {
        stopPolling()
    }

    // MARK: - Публичные методы (Public Methods)

    /// Начать мониторинг статуса сервера (polling каждые 10 секунд)
    func startPolling() {
        // Сначала проверить статус
        Task {
            await checkStatus()
        }

        // Запустить polling
        pollingTask = Task {
            [weak self] in
            while !Task.isCancelled {
                await self?.checkStatus()
                try ? await Task.sleep(nanoseconds: self?.pollingIntervalSeconds ?? 10 * 1_000_000_000)
            }
        }
    }

    /// Остановить мониторинг
    func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
    }

    /// Проверить текущий статус сервера
    func checkStatus() async {
        do {
            let result = try await serverStatusService.checkStatus()
            status = result
            errorMessage = nil
        } catch let error as NetworkError {
            status = .unavailable
            errorMessage = "Не удалось подключиться к серверу"
        } catch let error as ServerError {
            status = .unavailable
            switch error {
            case .serverStartFailed:
                errorMessage = "Не удалось запустить сервер"
            case .serverStopFailed:
                errorMessage = "Не удалось остановить сервер"
            case .sshHostNotConfigured:
                errorMessage = "SSH не настроен в настройках"
            }
        } catch {
            status = .unavailable
            errorMessage = error.localizedDescription
        }
    }

    /// Запустить сервер через SSH
    func startServer() async {
        isLoading = true
        status = .starting
        errorMessage = nil

        do {
            try await serverStatusService.startServer()
            // После запуска ждём немного и проверяем статус
            try ? await Task.sleep(nanoseconds: 3_000_000_000)
            await checkStatus()
        } catch let error as ServerError {
            status = .unavailable
            switch error {
            case .serverStartFailed:
                errorMessage = "Не удалось запустить сервер"
            case .serverStopFailed:
                errorMessage = "Не удалось остановить сервер"
            case .sshHostNotConfigured:
                errorMessage = "SSH не настроен в настройках"
            }
        } catch let error as NetworkError {
            status = .unavailable
            errorMessage = "Не удалось подключиться к серверу"
        } catch {
            status = .unavailable
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Остановить сервер через SSH
    func stopServer() async {
        isLoading = true
        status = .stopping
        errorMessage = nil

        do {
            try await serverStatusService.stopServer()
            // После остановки ждём немного и проверяем статус
            try ? await Task.sleep(nanoseconds: 2_000_000_000)
            await checkStatus()
        } catch let error as ServerError {
            status = .unavailable
            switch error {
            case .serverStartFailed:
                errorMessage = "Не удалось запустить сервер"
            case .serverStopFailed:
                errorMessage = "Не удалось остановить сервер"
            case .sshHostNotConfigured:
                errorMessage = "SSH не настроен в настройках"
            }
        } catch let error as NetworkError {
            status = .unavailable
            errorMessage = "Не удалось подключиться к серверу"
        } catch {
            status = .unavailable
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Вычисляемые свойства (Computed Properties)

    /// Текстовое описание статуса
    var statusText: String {
        switch status {
        case .unknown:
            return "Статус неизвестен"
        case .starting:
            return "Запуск..."
        case .running:
            return "Сервер работает"
        case .stopping:
            return "Остановка..."
        case .unavailable:
            return "Сервер недоступен"
        }
    }

    /// Доступна ли кнопка старта
    var canStart: Bool {
        status == .unavailable && !isLoading
    }

    /// Доступна ли кнопка стопа
    var canStop: Bool {
        status == .running && !isLoading
    }
}
