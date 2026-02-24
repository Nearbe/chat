// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.

import XCTest

/// Построитель конфигурации теста - паттерн fluent API.
/// Используется для настройки каждого теста через цепочку вызовов.
/// Пример: testConfiguration().metaData("FTD-T123").authorization(.token).build()
@MainActor
public final class TestConfigurationBuilder {

    private let configuration: Configuration

    /// Инициализация построеля.
    public init() {
        self.configuration = Configuration()
    }

    /// Установить метаданные теста.
    @discardableResult
    public func metaData(_ testKeyID: String, name: String = "", suite: String = "") -> TestConfigurationBuilder {
        let meta = Configuration.MetaData(
            name: name.isEmpty ? testKeyID: name,
            suite: suite,
            testKeyID: testKeyID
        )
        configuration.set(meta)
        return self
    }

    /// Установить тип авторизации.
    @discardableResult
    public func authorization(_ type: Configuration.AuthorizationType) -> TestConfigurationBuilder {
        configuration.set(authorizationType: type)
        return self
    }

    /// Установить анимации.
    @discardableResult
    public func animations(_ enabled: Bool) -> TestConfigurationBuilder {
        configuration.set(animations: enabled)
        return self
    }

    /// Очистка состояния.
    @discardableResult
    public func clearState(_ enabled: Bool) -> TestConfigurationBuilder {
        configuration.set(clearState: enabled)
        return self
    }

    /// Стартовый экран приложения.
    @discardableResult
    public func startScreen(_ screen: Configuration.StartScreen) -> TestConfigurationBuilder {
        configuration.set(startScreen: screen)
        return self
    }

    /// Адрес сервера API.
    @discardableResult
    public func apiURL(_ url: String) -> TestConfigurationBuilder {
        configuration.set(apiURL: url)
        return self
    }

    /// Учетные данные аккаунта.
    @discardableResult
    public func credentials(username: String, password: String, email: String = "") -> TestConfigurationBuilder {
        let creds = UTCredentials(username: username, password: password, email: email)
        configuration.set(accountCredentials: creds)
        return self
    }

    /// Построить и применить конфигурацию.
    public func build() -> Configuration {
        configuration.setup()
        return configuration
    }
}

/// Создать новый построитель конфигурации.
@MainActor
public func testConfiguration() -> TestConfigurationBuilder {
    TestConfigurationBuilder()
}
