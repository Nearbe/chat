// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.

import Foundation
import XCTest
import UIKit

/// Конфигурация запуска приложения для тестов
/// Аналог Configuration из tx-mobile
@MainActor
public final class Configuration {

    // MARK: - Типы

    /// Тип авторизации
    public enum AuthorizationType: String {
        /// Без авторизации
        case none
        /// Анонимная авторизация
        case anonymous
        /// Авторизованный пользователь
        case authorized
    }

    /// Стартовый экран приложения
    public enum StartScreen: String {
        /// Экран чата
        case chat
        /// Экран истории
        case history
        /// Экран настроек
        case settings
    }

    /// Метаданные теста
    public struct MetaData {
        /// Название теста
        public let name: String
        /// Название набора
        public let suite: String
        /// ID теста в TMS
        public let testKeyID: String

        /// Инициализация метаданных
        public init(name: String, suite: String, testKeyID: String) {
            self.name = name
            self.suite = suite
            self.testKeyID = testKeyID
        }
    }

    // MARK: - Свойства конфигурации

    /// Метаданные теста
    public var metaData: MetaData
    /// Тип авторизации
    public var authorizationType: AuthorizationType
    /// Флаг запуска приложения
    public var launch: Bool
    /// Флаг отключения анимаций
    public var animations: Bool
    /// Флаг очистки состояния
    public var clearState: Bool
    /// Стартовый экран
    public var startScreen: StartScreen
    /// Базовый URL API
    public var apiURL: String

    // MARK: - Computed

    /// Приложение для тестов
    public var app: XCUIApplication { testApp }

    // MARK: - Приватные

    private let testApp: XCUIApplication

    // MARK: - Инициализация

    /// Инициализация конфигурации
    public init(
        metaData: MetaData = MetaData(name: "", suite: "", testKeyID: ""),
        authorizationType: AuthorizationType = .none,
        launch: Bool = true,
        animations: Bool = false,
        clearState: Bool = true,
        startScreen: StartScreen = .chat,
    apiURL: String = ""
    ) {
        self.metaData = metaData
        self.authorizationType = authorizationType
        self.launch = launch
        self.animations = animations
        self.clearState = clearState
        self.startScreen = startScreen
        self.apiURL = apiURL
        self.testApp = XCUIApplication()
    }

    // MARK: - Fluent API

    /// Установить метаданные
    @discardableResult
    public func set(_ metaData: MetaData) -> Configuration {
        self.metaData = metaData
        return self
    }

    /// Установить тип авторизации
    @discardableResult
    public func set(authorizationType: AuthorizationType) -> Configuration {
        self.authorizationType = authorizationType
        return self
    }

    /// Установить флаг запуска
    @discardableResult
    public func set(launch: Bool) -> Configuration {
        self.launch = launch
        return self
    }

    /// Установить флаг анимаций
    @discardableResult
    public func set(animations: Bool) -> Configuration {
        self.animations = animations
        return self
    }

    /// Установить флаг очистки состояния
    @discardableResult
    public func set(clearState: Bool) -> Configuration {
        self.clearState = clearState
        return self
    }

    /// Установить стартовый экран
    @discardableResult
    public func set(startScreen: StartScreen) -> Configuration {
        self.startScreen = startScreen
        return self
    }

    /// Установить URL API
    @discardableResult
    public func set(apiURL: String) -> Configuration {
        self.apiURL = apiURL
        return self
    }

    /// Установить учетные данные аккаунта
    @discardableResult
    public func set(accountCredentials: UTCredentials) -> Configuration {
        AccountConfiguration.set(credentials: accountCredentials)
        return self
    }

    // MARK: - Authorize

    /// Авторизовать с указанными учетными данными
    @discardableResult
    public func authorize(username: String,
    password: String,
    email: String = "",
    apiToken: String = "") -> Configuration {
        let credentials = UTCredentials(
            username: username,
            password: password,
            email: email,
            apiToken: apiToken
        )
        AccountConfiguration.set(credentials: credentials)
        self.authorizationType = .authorized
        return self
    }

    /// Авторизовать анонимно
    @discardableResult
    public func authorizeAnonymously() -> Configuration {
        self.authorizationType = .anonymous
        return self
    }

    /// Авторизовать с токеном
    @discardableResult
    public func authorize(withToken token: String) -> Configuration {
        var creds = AccountConfiguration.current.credentials
        creds = UTCredentials(
            username: creds.username,
            password: creds.password,
            email: creds.email,
            apiToken: token
        )
        AccountConfiguration.set(credentials: creds)
        self.authorizationType = .authorized
        return self
    }

    /// Получить текущие учетные данные
    public func getCredentials() -> UTCredentials {
        AccountConfiguration.current.credentials
    }

    // MARK: - Setup

    /// Настройка конфигурации
    @discardableResult
    public func setup() -> Configuration {
        XCTAssert(!metaData.testKeyID.isEmpty, "Необходимо указать TestKeyID")

        XCTContext.runActivity(named: "TestKey ID: \(metaData.testKeyID)") { _ in }
        XCTContext.runActivity(named: "Очистка состояния: \(clearState)") { _ in }
        XCTContext.runActivity(named: "Запуск приложения: \(launch)") { _ in }
        XCTContext.runActivity(named: "Анимации: \(animations ? "выкл" : "вкл")") { _ in }
        XCTContext.runActivity(named: "Тип авторизации: \(authorizationType)") { _ in }
        XCTContext.runActivity(named: "Стартовый экран: \(startScreen)") { _ in }

        return self
    }

    // MARK: - Launch Environment

    /// Установить переменные окружения для запуска
    public func setLaunchEnvironment() {
        XCTContext.runActivity(named: "Установка launch environments") { _ in
            testApp.launchEnvironment = [:]testApp.launchEnvironment[LaunchEnv.isUITests]= "true" testApp.launchEnvironment[LaunchEnv.animations]= "\(! animations )" testApp.launchEnvironment[LaunchEnv.clearState]= "\(clearState)" testApp.launchEnvironment[LaunchEnv.startScreen]= startScreen.rawValue testApp.launchEnvironment[LaunchEnv.apiBaseURL]= apiURL testApp.launchEnvironment[LaunchEnv.apiTestMode]= "true"

            switch authorizationType {
            case .none:
                break
            case .anonymous: testApp.launchEnvironment[LaunchEnv.authorization]= "anonymous"
            case .authorized:
            testApp.launchEnvironment[LaunchEnv.authorization]= "authorized" testApp.launchEnvironment[LaunchEnv.isEulaAccepted] = "true"
            }
        }
    }

    // MARK: - Launch

            /// Запустить приложение
    public func launchApp() {
        setLaunchEnvironment()
        testApp.launchArguments = ["-ui-tests"]

        if clearState {
            testApp.launchArguments.append("-reset")
        }

        testApp.launch()
    }

            /// Перезапустить приложение
    public func terminateAndRelaunch() {
        testApp.terminate()
        launchApp()
    }
}

// MARK: - Глобальная переменная

/// Глобальная конфигурация для тестов
@MainActor
public var configuration = Configuration()
