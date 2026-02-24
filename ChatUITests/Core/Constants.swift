// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.

import Foundation
import XCTest

/// Главное приложение XCUI для UI-тестов
@MainActor public let app = XCUIApplication()
/// Таймаут по умолчанию для действий
public let defaultTimeout: TimeInterval = 5
/// Таймаут для поиска элементов
public let elementTimeout: TimeInterval = 5
/// Таймаут для сетевых операций
public let networkTimeout: TimeInterval = 10
/// Включено ли логирование в файл
public var shouldEnableLogs: Bool = true

// MARK: - Log Paths

// MARK: - Связь с документацией: Тесты

/// Путь к файлу логов тестов
public var logFilePath: String {
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first !
    let logsDirectory = documentsPath.appendingPathComponent("Logs", isDirectory: true)
    return logsDirectory.appendingPathComponent("test_log.txt").path
}

/// URL файла логов тестов
public var logFileURL: URL {
    URL(fileURLWithPath: logFilePath)
}

/// Путь к логам приложения
public var appLogsFilePath: String {
    let containerPath = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first !
    return containerPath.appendingPathComponent("Logs", isDirectory: true).path
}

/// URL логов приложения
public var appLogsFileURL: URL {
    URL(fileURLWithPath: appLogsFilePath)
}

// MARK: - Launch Environment Keys

/// Ключи окружения для запуска приложения в тестах.
/// Используются для централизованного управления переменными окружения.
public enum LaunchEnv {
    /// Ключ для определения режима UI-тестов
    public static let isUITests = "isUITests"
    /// Ключ для включения/отключения анимаций
    public static let animations = "Animations"
    /// Ключ для очистки состояния перед запуском
    public static let clearState = "ClearState"
    /// Ключ для указания стартового экрана
    public static let startScreen = "StartScreen"
    /// Ключ для базового URL API
    public static let apiBaseURL = "APIBaseURL"
    /// Ключ для режима тестирования API
    public static let apiTestMode = "API_TEST_MODE"
    /// Ключ для типа авторизации
    public static let authorization = "Authorization"
    /// Ключ для подтверждения EULA
    public static let isEulaAccepted = "isEulaAccepted"
}

// MARK: - UTCredentials

/// Структура учетных данных для авторизации.
/// Аналог UTCredentials из tx-mobile.
public struct UTCredentials {
    /// Имя пользователя.
    public let username: String
    /// Пароль.
    public let password: String
    /// Электронная почта.
    public let email: String
    /// API токен.
    public let apiToken: String

    /// Инициализация.
    public init(username: String = "",
    password: String = "",
    email: String = "",
    apiToken: String = "") {
        self.username = username
        self.password = password
        self.email = email
        self.apiToken = apiToken
    }
}

/// Типы аккаунтов для авторизации.
/// Аналог UTAccount из tx-mobile.
public enum UTAccountType: String, CaseIterable {
    /// Основной аккаунт (LK).
    case lk = "LK"
    /// Демо аккаунт.
    case demo = "DEMO"
    /// Персональный аккаунт.
    case personal = "PERSONAL"
    /// Неопознанный пользователь.
    case nedopersona = "NEDOPERSONA"

    /// Получить учетные данные из переменных окружения.
    public var credentials: UTCredentials {
        let login = ProcessInfo.processInfo.environment["\(rawValue)_LOGIN"] ?? ""
        let password = ProcessInfo.processInfo.environment["\(rawValue)_PASSWORD"] ?? ""
        let pin = ProcessInfo.processInfo.environment["\(rawValue)_PIN"] ?? "1111"
        let email = ProcessInfo.processInfo.environment["\(rawValue)_EMAIL"] ?? ""
        return UTCredentials(username: login, password: password, pin: pin, email: email)
    }
}

// MARK: - UTAccount

/// Структура аккаунта для тестов
/// Аналог UTAccount из tx-mobile
public struct UTAccount {
    /// Учетные данные
    public let credentials: UTCredentials
    /// Тип аккаунта
    public let accountType: AccountType

    /// Тип аккаунта
    public enum AccountType: String {
        case anonymous
        case free
        case premium
        case admin
    }

    /// Инициализация
    public init(credentials: UTCredentials = UTCredentials(),
    accountType: AccountType = .anonymous) {
        self.credentials = credentials
        self.accountType = accountType
    }
}

/// Конфигурация аккаунта
@MainActor
public final class AccountConfiguration {
    /// Текущий аккаунт
    public static var current: UTAccount = UTAccount()

    /// Установить учетные данные
    public static func set(credentials: UTCredentials) {
        current = UTAccount(credentials: credentials, accountType: current.accountType)
    }

    /// Установить тип аккаунта
    public static func set(accountType: UTAccount.AccountType) {
        current = UTAccount(credentials: current.credentials, accountType: accountType)
    }
}

/// Глобальные учетные данные для тестов
@MainActor
public var account = AccountConfiguration.self
