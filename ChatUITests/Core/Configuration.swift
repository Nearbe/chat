// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.

import Foundation
import XCTest
import UIKit

/// Конфигурация запуска приложения для тестов
/// Аналог Configuration из tx-mobile
@MainActor
public final class Configuration {

    // MARK: - Типы

    public enum AuthorizationType: String {
        case none
        case anonymous
        case authorized
    }

    public enum StartScreen: String {
        case chat
        case history
        case settings
    }

    public struct MetaData {
        public let name: String
        public let suite: String
        public let testKeyID: String

        public init(name: String, suite: String, testKeyID: String) {
            self.name = name
            self.suite = suite
            self.testKeyID = testKeyID
        }
    }

    // MARK: - Свойства конфигурации

    public var metaData: MetaData
    public var authorizationType: AuthorizationType
    public var launch: Bool
    public var animations: Bool
    public var clearState: Bool
    public var startScreen: StartScreen
    public var apiURL: String

    // MARK: - Computed

    public var app: XCUIApplication { testApp }

    // MARK: - Приватные

    private let testApp: XCUIApplication

    // MARK: - Инициализация

    public init(
        metaData: MetaData = MetaData(name: "", suite: "", testKeyID: ""),
        authorizationType: AuthorizationType = .none,
        launch: Bool = true,
        animations: Bool = false,
        clearState: Bool = true,
        startScreen: StartScreen = .chat,
        apiURL: String = "http://192.168.1.91:64721"
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

    @discardableResult
    public func set(_ metaData: MetaData) -> Configuration {
        self.metaData = metaData
        return self
    }

    @discardableResult
    public func set(authorizationType: AuthorizationType) -> Configuration {
        self.authorizationType = authorizationType
        return self
    }

    @discardableResult
    public func set(launch: Bool) -> Configuration {
        self.launch = launch
        return self
    }

    @discardableResult
    public func set(animations: Bool) -> Configuration {
        self.animations = animations
        return self
    }

    @discardableResult
    public func set(clearState: Bool) -> Configuration {
        self.clearState = clearState
        return self
    }

    @discardableResult
    public func set(startScreen: StartScreen) -> Configuration {
        self.startScreen = startScreen
        return self
    }

    @discardableResult
    public func set(apiURL: String) -> Configuration {
        self.apiURL = apiURL
        return self
    }

    // MARK: - Setup

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

    public func setLaunchEnvironment() {
        XCTContext.runActivity(named: "Установка launch environments") { _ in
            testApp.launchEnvironment = [:]
            testApp.launchEnvironment["isUITests"] = "true"
            testApp.launchEnvironment["Animations"] = "\(!animations)"
            testApp.launchEnvironment["ClearState"] = "\(clearState)"
            testApp.launchEnvironment["StartScreen"] = startScreen.rawValue
            testApp.launchEnvironment["APIBaseURL"] = apiURL
            testApp.launchEnvironment["API_TEST_MODE"] = "true"

            switch authorizationType {
            case .none:
                break
            case .anonymous:
                testApp.launchEnvironment["Authorization"] = "anonymous"
            case .authorized:
                testApp.launchEnvironment["Authorization"] = "authorized"
                testApp.launchEnvironment["isEulaAccepted"] = "true"
            }
        }
    }

    // MARK: - Launch

    public func launchApp() {
        setLaunchEnvironment()
        testApp.launchArguments = ["-ui-tests"]

        if clearState {
            testApp.launchArguments.append("-reset")
        }

        testApp.launch()
    }

    public func terminateAndRelaunch() {
        testApp.terminate()
        launchApp()
    }
}

// MARK: - Глобальная переменная

@MainActor
public var configuration = Configuration()
