// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.

import Foundation

/// Результат теста в реальном времени.
struct LiveTestResult: Sendable {
    let name: String
    let status: TestStatus
    let duration: TimeInterval
    let device: String

    enum TestStatus: Sendable {
        case passed
        case failed
        case started

        var icon: String {
            switch self {
            case .passed:
                return "✅"
            case .failed:
                return "❌"
            case .started:
                return "🔄"
            }
        }
    }
}

/// Сервис для парсинга вывода тестов в реальном времени.
enum TestStreamParser {
    /// Паттерн для парсинга строки с результатом теста.
    /// Формат: Test case 'TestName' passed/failed on 'Device' (0.000 seconds)
    private static let testCasePattern = #"Test case '(.*?)' (passed|failed|started) on '(.*?)' \(([\ d.]+) seconds \)"#

    /// Паттерн для количества попыток.
    private static let attemptPattern = #"\((\ d +) attempts ? \)"#

    /// Парсит строку вывода теста.
    static func parseLine(_ line: String) -> LiveTestResult? {
        guard let regex = try? NSRegularExpression(pattern: testCasePattern, options: []),
        let match = regex.firstMatch(in: line, options: [], range: NSRange(line.startIndex..<line.endIndex, in: line)) else {
            return nil
        }

        guard let nameRange = Range(match.range(at: 1), in: line),
        let statusRange = Range(match.range(at: 2), in: line),
        let deviceRange = Range(match.range(at: 3), in: line),
        let durationRange = Range(match.range(at: 4), in: line) else {
            return nil
        }

        let name = String(line[nameRange])
        let statusStr = String(line[statusRange])
        let device = String(line[deviceRange])
        let durationStr = String(line[durationRange])

        let status: LiveTestResult.TestStatus
        switch statusStr {
        case "passed":
            status = .passed
        case "failed":
            status = .failed
        case "started":
            status = .started
        default:
            return nil
        }

        let duration = Double(durationStr) ?? 0

        return LiveTestResult(name: name, status: status, duration: duration, device: device)
    }

    /// Извлекает количество попыток из строки.
    static func parseAttempts(_ line: String) -> Int? {
        guard let regex = try? NSRegularExpression(pattern: attemptPattern, options: []),
        let match = regex.firstMatch(in: line, options: [], range: NSRange(line.startIndex..<line.endIndex, in: line)),
        let range = Range(match.range(at: 1), in: line) else {
            return nil
        }
        return Int(line[range])
    }

    /// Выводит результат теста в красивом формате.
    static func printTestResult(_ result: LiveTestResult, attempts: Int? = nil) {
        let durationStr = String(format: "%.3fs", result.duration)
        var output = "  \(result.status.icon) \(result.name) [\(durationStr)]"

        if let attempts = attempts, attempts > 1 {
            output += " (\(attempts) attempts)"
        }

        print(output)
    }

    /// Обрабатывает строку вывода и выводит результат.
    static func processLine(_ line: String) {
        guard let result = parseLine(line) else {
            return
        }

        let attempts = parseAttempts(line)
        printTestResult(result, attempts: attempts)
    }

    /// Обрабатывает весь вывод тестов.
    static func processOutput(_ output: String) {
        let lines = output.components(separatedBy: .newlines)
        for line in lines {
            processLine(line)
        }
    }
}
