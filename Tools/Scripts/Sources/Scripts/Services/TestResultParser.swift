// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import Foundation
import XCResultKit

/// Результат парсинга теста.
struct ParsedTestResult: Sendable {
    let targetName: String
    let testName: String
    let status: String
    let duration: TimeInterval

    var icon: String {
        status == "Success" ? "🍀" : "❌"
    }
}

/// Сервис для парсинга результатов тестов.
enum TestResultParser {
    /// Парсит результаты тестов из xcresult.
    static func parse(resultBundlePath: String) async -> [ParsedTestResult] {
        let xcresultURL = URL(fileURLWithPath: resultBundlePath)
        guard FileManager.default.fileExists(atPath: resultBundlePath) else { return [] }

        do {
            let resultFile = XCResultFile(url: xcresultURL)
            guard let invocationRecord = resultFile.getInvocationRecord() else { return [] }

            var results: [ParsedTestResult] = []

            for action in invocationRecord.actions {
                guard let testPlanRun = action.actionResult.testsRef?.id else { continue }

                if let summaries = resultFile.getTestPlanRunSummaries(id: testPlanRun) {
                    for summary in summaries.summaries {
                        for testable in summary.testableSummaries {
                            for test in testable.tests {
                                if let summaryID = test.summary,
                                   let testSummary = resultFile.getActionTestSummary(id: summaryID) {
                                    let result = ParsedTestResult(
                                        targetName: testable.targetName ?? "Unknown",
                                        testName: test.name ?? "unknown",
                                        status: testSummary.testStatus ?? "unknown",
                                        duration: testSummary.duration
                                    )
                                    results.append(result)
                                }
                            }
                        }
                    }
                }
            }

            return results
        } catch {
            return []
        }
    }

    /// Выводит результаты тестов в консоль.
    static func printResults(_ results: [ParsedTestResult]) {
        print("\n📋  Результаты тестов:")

        for result in results {
            let durationFormatted = String(format: "%.3fs", result.duration)
            print("  \(result.icon) \(result.targetName)/\(result.testName) [\(durationFormatted)]")
        }
    }

    /// Выводит результаты из xcresult файла.
    static func printResultsFromFile(_ resultBundlePath: String) async {
        let results = await parse(resultBundlePath: resultBundlePath)
        printResults(results)
    }
}
