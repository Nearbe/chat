// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import Foundation

/// Централизованное хранилище версий всех инструментов и зависимостей проекта.
enum Versions {
    // MARK: - Инструменты (CLI)

    /// Версия XcodeGen для генерации .xcodeproj
    static let xcodegen = "2.44.1"

    /// Версия SwiftGen для генерации ресурсов
    static let swiftgen = "6.6.3"

    /// Версия SwiftLint для проверки стиля кода
    static let swiftlint = "0.63.2"

    // MARK: - Языки и Платформы

    /// Версия Swift
    static let swift = "6.0"

    /// Минимальная версия iOS
    static let iOS = "26.2"

    /// Минимальная версия macOS (для инструментов)
    static let macOS = "14.0"

    // MARK: - Зависимости (SPM)

    /// Factory (Внедрение зависимостей / Dependency Injection)
    static let factory = "2.3.0"

    /// Pulse (Логирование и мониторинг сети / Logging & Network Monitoring)
    static let pulse = "4.0.0"

    /// SnapshotTesting (Визуальное регрессионное тестирование / Visual Regression Testing)
    static let snapshotTesting = "1.15.4"

    // MARK: - Внешние API и Документация

    /// Ревизия документации LM Studio (ветка или тег)
    static let lmStudioDocs = "main"

    /// Ревизия спецификации OpenAI OpenAPI
    static let openAIDocs = "manual_spec"

    /// Ревизия документации Ollama
    static let ollamaDocs = "main"
}
