// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.

import Foundation

/// Информация об инструменте
private struct ToolInfo {
    let name: String
    let brewName: String
    let version: String
}

/// Сервис для проверки и установки системных зависимостей проекта.
enum DependencyService {
    /// Список необходимых инструментов с их названиями для Homebrew
    private static let requiredTools: [ToolInfo] = [
        ToolInfo(name: "xcodegen", brewName: "xcodegen", version: Versions.xcodegen),
        ToolInfo(name: "swiftgen", brewName: "swiftgen", version: Versions.swiftgen),
        ToolInfo(name: "swiftlint", brewName: "swiftlint", version: Versions.swiftlint)
    ]

    /// Проверяет и устанавливает все необходимые зависимости
    static func ensureDependencies() async throws {
        print("🔍 Проверка системных зависимостей...")

        for tool in requiredTools {
            try await ensureTool(name: tool.name, brewName: tool.brewName, version: tool.version)
        }

        print("✅ Все зависимости установлены")
    }

    /// Проверяет наличие инструмента и устанавливает если отсутствует
    private static func ensureTool(name: String, brewName: String, version: String) async throws {
        let installedVersion = try ? await getInstalledVersion(of: name)

        if let installed = installedVersion {
            print("  ✅ \(name) (\(installed)) уже установлен")
            return
        }

        print("  ⚠️  \(name) не найден. Установка через Homebrew...")

        let brewPath = try ? await getBrewPath()
        guard let brew = brewPath else {
            throw DependencyError.brewNotFound
        }

        try await installTool(name: name, brewName: brewName, brewPath: brew)
    }

    /// Получает установленную версию инструмента
    private static func getInstalledVersion(of tool: String) async throws -> String? {
        let whichCommand = "which \(tool)"
        let whichOutput = try await Shell.run(whichCommand, quiet: true)

        guard !whichOutput.isEmpty else {
            return nil
        }

        // Для некоторых инструментов версия проверяется по-разному
        let versionCommand: String
        switch tool {
        case "xcodegen":
            versionCommand = "\(tool) --version"
        case "swiftgen":
            versionCommand = "\(tool) --version"
        case "swiftlint":
            versionCommand = "\(tool) --version"
        default:
            versionCommand = "\(tool) --version"
        }

        let output = try await Shell.run(versionCommand, quiet: true)

        // Извлекаем версию из вывода (формат может быть разным)
        // Ожидаемый формат: "X.Y.Z" или "X.Y.Z (YYYY-MM-DD)"
        let versionPattern = #"(\d+\.\d+\.\d+)"#
        guard let regex = try ? NSRegularExpression(pattern: versionPattern),
        let match = regex.firstMatch(in: output, range: NSRange(output.startIndex ..., in: output)),
        let range = Range(match.range(at: 1), in: output) else {
            return nil
        }

        return String(output[range])
    }

    /// Возвращает путь к Homebrew
    private static func getBrewPath() async throws -> String? {
        let output = try await Shell.run("which brew", quiet: true)
        return output.isEmpty ? nil: output.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Устанавливает инструмент через Homebrew
    private static func installTool(name: String, brewName: String, brewPath: String) async throws {
        let installCommand = "\(brewPath) install \(brewName)"

        print("  📦 Установка \(name)...")
        _ = try await Shell.run(installCommand)

        // Проверяем, что установка прошла успешно
        if let version = try ? await getInstalledVersion(of: name) {
            print("  ✅ \(name) (\(version)) успешно установлен")
        } else {
            throw DependencyError.installationFailed(tool: name)
        }
    }
}

/// Ошибки, возникающие при работе с зависимостями
enum DependencyError: Error, LocalizedError {
    case brewNotFound
    case installationFailed(tool: String)

    var errorDescription: String? {
        switch self {
        case .brewNotFound:
            return "Homebrew не найден. Установите Homebrew: https://brew.sh"
        case .installationFailed(let tool):
            return "Не удалось установить \(tool)"
        }
    }
}
