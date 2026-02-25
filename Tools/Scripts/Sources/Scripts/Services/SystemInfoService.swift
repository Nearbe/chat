// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.

import Foundation

/// Сервис для получения информации о системе.
/// Предоставляет унифицированный доступ к версиям Xcode, Swift, macOS.
struct SystemInfoService {
    /// Информация о системе
    struct SystemInfo {
        let xcodeVersion: String
        let swiftVersion: String
        let macOSVersion: String
        let macOSName: String
    }

    /// Получить полную информацию о системе
    static func getSystemInfo() -> SystemInfo {
        SystemInfo(
            xcodeVersion: getXcodeVersion(),
            swiftVersion: getSwiftVersion(),
            macOSVersion: getMacOSVersion(),
            macOSName: getMacOSVersionName()
        )
    }

    /// Выводит информацию о системе в консоль
    static func printSystemInfo() {
        let info = getSystemInfo()
        print("📋  Системная информация:")
        print("   - Xcode: \(info.xcodeVersion)")
        print("   - Swift: \(info.swiftVersion)")
        print("   - macOS: \(info.macOSVersion)")
        print()
    }

    // MARK: - Приватные методы

    /// Получить версию Xcode
    private static func getXcodeVersion() -> String {
        let output = runCommand("/usr/bin/xcodebuild", arguments: ["-version"])
        let lines = output.components(separatedBy: "\n")
        if let versionLine = lines.first(where: {
            $0.hasPrefix("Xcode")
        }) {
            return versionLine.trimmingCharacters(in: .whitespaces)
        }
        return "Unknown"
    }

    /// Получить версию Swift
    private static func getSwiftVersion() -> String {
        let output = runCommand("/usr/bin/swift", arguments: ["--version"])
        let line = output.components(separatedBy: "\n").first ?? ""
        return line.trimmingCharacters(in: .whitespaces)
    }

    /// Получить версию macOS
    private static func getMacOSVersion() -> String {
        let version = runCommand("/usr/bin/sw_vers", arguments: ["-productVersion"]).trimmingCharacters(in: .whitespacesAndNewlines)
        let name = getMacOSVersionName()
        return "\(version) (\(name))"
    }

    /// Получить кодовое имя версии macOS
    private static func getMacOSVersionName() -> String {
        let version = runCommand("/usr/bin/sw_vers", arguments: ["-productVersion"]).trimmingCharacters(in: .whitespacesAndNewlines)

        let majorVersion = version.split(separator: ".").first.flatMap {
            Int($0)
        } ?? 0

        switch majorVersion {
        case 14:
            return "Sonoma"
        case 13:
            return "Ventura"
        case 12:
            return "Monterey"
        case 11:
            return "Big Sur"
        case 10:
            return "Catalina"
        default:
            return "Unknown"
        }
    }

    /// Универсальный метод для запуска команды
    private static func runCommand(_ path: String, arguments: [String]) -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: path)
        process.arguments = arguments

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice

        do {
            try process.run()
            process.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            return ""
        }
    }
}
