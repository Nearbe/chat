// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import Foundation
import XCResultKit

/// Сервис для запуска тестов.
enum TestRunner {
    /// Дефолтное устройство для тестов.
    static let defaultDevice = "platform=iOS Simulator,name=iPhone 16 Pro Max"

    /// Путь к директории результатов тестов.
    static let resultsDirectory = "/Users/nearbe/repositories/Chat/Logs/Check"

    /// Запускает тесты с указанным тест-планом.
    static func runTests(
        testPlan: String,
        device: String = defaultDevice,
        logName: String
    ) async throws -> String {
        let resultPath = "\(resultsDirectory)/\(logName).xcresult"
        try? FileManager.default.removeItem(atPath: resultPath)

        let testCommand = [
            "cd /Users/nearbe/repositories/Chat && xcodebuild",
            "-project Chat.xcodeproj",
            "-scheme Chat",
            "-testPlan \(testPlan)",
            "-destination \"\(device)\"",
            "-resultBundlePath \(resultPath)",
            "test",
            "CODE_SIGNING_ALLOWED=NO",
            "CODE_SIGNING_REQUIRED=NO"
        ].joined(separator: " ")

        let allowedWarnings = (try? ExceptionRegistry.loadSystemWarnings()) ?? []
        try await Shell.run(testCommand, quiet: true, failOnWarnings: false, allowedWarnings: allowedWarnings, logName: logName)

        return resultPath
    }

    /// Запускает Unit тесты.
    static func runUnitTests(device: String = defaultDevice) async throws -> (resultPath: String, duration: TimeInterval) {
        let startTime = Date()
        let resultPath = try await runTests(testPlan: "UnitTests", device: device, logName: "UnitTests")
        let duration = Date().timeIntervalSince(startTime)
        return (resultPath, duration)
    }

    /// Запускает UI тесты.
    static func runUITests(device: String = defaultDevice) async throws -> (resultPath: String, duration: TimeInterval) {
        let startTime = Date()
        let resultPath = try await runTests(testPlan: "UITests", device: device, logName: "UITests")
        let duration = Date().timeIntervalSince(startTime)
        return (resultPath, duration)
    }

    /// Запускает все тесты.
    static func runAllTests(device: String = defaultDevice) async throws -> [(name: String, resultPath: String, duration: TimeInterval)] {
        var results: [(name: String, resultPath: String, duration: TimeInterval)] = []

        let unitResult = try await runUnitTests(device: device)
        results.append((name: "Unit Tests", resultPath: unitResult.resultPath, duration: unitResult.duration))

        let uiResult = try await runUITests(device: device)
        results.append((name: "UI Tests", resultPath: uiResult.resultPath, duration: uiResult.duration))

        return results
    }

    /// Проверяет покрытие кода.
    static func checkCoverage(resultBundlePath: String, targetName: String, expected: Double) async throws {
        let command = "xcrun xccov view --report --json \(resultBundlePath)"
        let jsonString = try await Shell.run(command, quiet: true)

        guard let data = jsonString.data(using: .utf8) else {
            throw CheckError.coverageCheckFailed("Не удалось распарсить JSON отчета о покрытии")
        }

        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let targets = json["targets"] as? [[String: Any]] {
            for target in targets {
                if let name = target["name"] as? String, name.contains(targetName) {
                    if let lineCoverage = target["lineCoverage"] as? Double {
                        let percentage = lineCoverage * 100.0
                        if percentage < expected {
                            throw CheckError.lowCoverage(target: name, actual: percentage, expected: expected)
                        }
                        return
                    }
                }
            }
        }
        throw CheckError.coverageCheckFailed("Таргет \(targetName) не найден в отчете о покрытии")
    }
}
