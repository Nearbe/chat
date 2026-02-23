// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import ArgumentParser
import Foundation

/// Команда для выполнения полной технической проверки проекта (Lint, Build, Test, Commit).
struct Check: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Техническая проверка проекта (Lint + Build + Test + Commit)")

    @Argument(help: "Сообщение для коммита")
    var message: String?

    /// Основная логика выполнения шагов проверки.
    func run() async throws {
        let device = "platform=iOS Simulator,name=iPhone 16 Pro Max"
        print("🚀  Начало технической проверки...")

        var allResults: [CheckStepResult] = []
        allResults += await runLintAndProjectChecks()

        let infra = await runInfrastructure()
        allResults.append(infra.xcodegen)
        allResults.append(infra.swiftgen)

        if case .failure = infra.xcodegen {
            print("⚠️  XcodeGen завершился с ошибкой, этап сборки будет пропущен.")
        } else {
            allResults += await runTestsAndBuild(device: device)
        }

        let hasProblems = printSummary(results: allResults)
        if hasProblems {
            print("\n❌  Техническая проверка не пройдена из-за наличия предупреждений или ошибок.")
            throw ExitCode(1)
        }

        print("\n✅  Техническая проверка успешно завершена!")
        try await Metrics.measure(step: "Git Commit & Push") {
            try await handleGitCommit()
        }
    }

    private func runLintAndProjectChecks() async -> [CheckStepResult] {
        async let lintResult = performStep("SwiftLint") {
            try await Shell.run("swiftlint --strict", quiet: true, logName: "SwiftLint")
        }

        async let checkerResult = performStep("ProjectChecker") {
            try await ProjectChecker.run()
        }
        return await [lintResult, checkerResult]
    }

    private func runInfrastructure() async -> (xcodegen: CheckStepResult, swiftgen: CheckStepResult) {
        async let xcodegen = performStep("XcodeGen") {
            try await Shell.run("xcodegen generate", quiet: true, logName: "XcodeGen")
        }
        async let swiftgen = performStep("SwiftGen") {
            try await runSwiftGen()
        }
        return await (xcodegen, swiftgen)
    }

    private func runTestsAndBuild(device: String) async -> [CheckStepResult] {
        print("⏳  Запуск тестов и сборки Release в параллельном режиме...")

        async let testsResult = performStep("Tests") {
            let resultPath = "TestResult.xcresult"
            try? FileManager.default.removeItem(atPath: resultPath)

            let testCommand = [
                "xcodebuild",
                "-project Chat.xcodeproj",
                "-scheme Chat",
                "-testPlan AllTests",
                "-destination \"\(device)\"",
                "-resultBundlePath \(resultPath)",
                "-parallel-testing-enabled YES",
                "test",
                "CODE_SIGNING_ALLOWED=NO",
                "CODE_SIGNING_REQUIRED=NO",
                "2>&1 | grep -E \"Test Suite|passed|failed|skipped|warning:\""
            ].joined(separator: " ")

            let allowedWarnings = (try? ExceptionRegistry.loadSystemWarnings()) ?? []
            try await Shell.run(testCommand, quiet: true, failOnWarnings: true, allowedWarnings: allowedWarnings, logName: "Tests")
            // Временно ожидаем 50% покрытия, согласно плану (~50%)
            try await checkCoverage(resultBundlePath: resultPath, targetName: "Chat", expected: 50.0)
        }

        async let buildResult = performStep("Build Release") {
            let releaseCommand = [
                "xcodebuild",
                "-quiet",
                "-project Chat.xcodeproj",
                "-scheme Chat",
                "-configuration Release",
                "-destination \"generic/platform=iOS\"",
                "SYMROOT=\"$(pwd)/build\"",
                "build"
            ].joined(separator: " ")
            try await Shell.run(releaseCommand, quiet: true, logName: "Build Release")
        }

        return await [testsResult, buildResult]
    }

    private func performStep(_ name: String, action: @escaping () async throws -> Void) async -> CheckStepResult {
        let startTime = Date()
        do {
            try await Metrics.measure(step: name) {
                try await action()
            }
            return .success(step: name, duration: Date().timeIntervalSince(startTime))
        } catch let error as ShellError {
            switch error {
            case .warningsFound(let command, let output):
                return .warning(step: name, command: command, output: output, duration: Date().timeIntervalSince(startTime))
            case .commandFailed(let command, _, let output, let errorMsg):
                return .failure(step: name, command: command, output: "\(output)\n\(errorMsg)", error: error, duration: Date().timeIntervalSince(startTime))
            }
        } catch {
            return .failure(step: name, command: nil, output: nil, error: error, duration: Date().timeIntervalSince(startTime))
        }
    }

    private func printSummary(results: [CheckStepResult]) -> Bool {
        let warnings = results.filter { if case .warning = $0 { return true }; return false }
        let failures = results.filter { if case .failure = $0 { return true }; return false }

        printSummaryHeader()

        for result in results {
            printResultRow(result)
        }

        if !warnings.isEmpty {
            printWarningsDetails(warnings)
        }

        if !failures.isEmpty {
            printFailuresDetails(failures)
        }

        print(String(repeating: "=", count: 60))

        return !warnings.isEmpty || !failures.isEmpty
    }

    private func printSummaryHeader() {
        print("\n" + String(repeating: "=", count: 60))
        print("📊  ИТОГОВЫЙ ОТЧЕТ ПРОВЕРКИ")
        print(String(repeating: "=", count: 60))
    }

    private func printResultRow(_ result: CheckStepResult) {
        let duration = String(format: "%.2fs", result.duration)
        switch result {
        case .success(let step, _):
            print("✅ [\(duration)] \(step): OK")
        case .warning(let step, _, _, _):
            print("⚠️ [\(duration)] \(step): ВНИМАНИЕ (Warnings found)")
        case .failure(let info):
            print("❌ [\(duration)] \(info.step): ОШИБКА (Failed)")
        }
    }
}

// MARK: - Вспомогательные структуры
extension Check {
    /// Информация об ошибке на конкретном шаге проверки.
    struct CheckStepFailureInfo {
        let step: String
        let command: String?
        let output: String?
        let error: Error
        let duration: TimeInterval
    }

    /// Результат выполнения шага проверки (успех, предупреждение или ошибка).
    enum CheckStepResult {
        case success(step: String, duration: TimeInterval)
        case warning(step: String, command: String?, output: String, duration: TimeInterval)
        case failure(info: CheckStepFailureInfo)

        var duration: TimeInterval {
            switch self {
            case .success(_, let duration), .warning(_, _, _, let duration):
                return duration
            case .failure(let info):
                return info.duration
            }
        }

        static func failure(step: String, command: String?, output: String?, error: Error, duration: TimeInterval) -> CheckStepResult {
            .failure(info: CheckStepFailureInfo(step: step, command: command, output: output, error: error, duration: duration))
        }
    }

    /// Ошибки, специфичные для процесса проверки (например, низкое покрытие).
    enum CheckError: Error, LocalizedError {
        case coverageCheckFailed(String)
        case lowCoverage(target: String, actual: Double, expected: Double)

        var errorDescription: String? {
            switch self {
            case .coverageCheckFailed(let message):
                return "Ошибка проверки покрытия: \(message)"
            case .lowCoverage(let target, let actual, let expected):
                return "Низкое покрытие кода для \(target): \(String(format: "%.2f", actual))% (ожидается \(String(format: "%.2f", expected))%)"
            }
        }
    }
}

// MARK: - Детализированный вывод и вспомогательные функции
extension Check {
    private func printWarningsDetails(_ warnings: [CheckStepResult]) {
        print("\n⚠️  ДЕТАЛИ ПРЕДУПРЕЖДЕНИЙ:")
        for warning in warnings {
            if case .warning(let step, _, _, _) = warning {
                let logFile = "Logs/Check/\(step.replacingOccurrences(of: " ", with: "_")).log"
                print("  - \(step): Найдены предупреждения. Подробности: \(logFile)")
            }
        }
    }

    private func printFailuresDetails(_ failures: [CheckStepResult]) {
        print("\n❌  ДЕТАЛИ ОШИБОК:")
        for failure in failures {
            if case .failure(let info) = failure {
                let logFile = "Logs/Check/\(info.step.replacingOccurrences(of: " ", with: "_")).log"
                print("  - \(info.step): Ошибка: \(info.error.localizedDescription)")
                print("    Подробный вывод: \(logFile)")
            }
        }
    }

    private func runSwiftGen() async throws {
        try await Shell.run("swiftgen", quiet: true, logName: "SwiftGen")
        let assetsFile = URL(fileURLWithPath: "Design/Generated/Assets.swift")
        if FileManager.default.fileExists(atPath: assetsFile.path) {
            var content = try String(contentsOf: assetsFile, encoding: .utf8)
            content = content.replacingOccurrences(
                of: "internal final class ColorAsset",
                with: "internal final class ColorAsset: @unchecked Sendable"
            )
            try content.write(to: assetsFile, atomically: true, encoding: .utf8)
        }
    }

    private func handleGitCommit() async throws {
        let status = try await Shell.run("git status --porcelain", quiet: true)
        if !status.isEmpty {
            let commitMessage = message ?? "Automatic commit after successful verification"
            try await Shell.run("git add .", quiet: true, logName: "Git Add")
            try await Shell.run("git commit -m \"\(commitMessage)\"", quiet: true, logName: "Git Commit")
            try await Shell.run("git push", quiet: true, logName: "Git Push")
            print("🚀  Код закоммичен и отправлен!")
        } else {
            print("ℹ️  Изменений не обнаружено, коммит не требуется.")
        }
    }

    private func checkCoverage(resultBundlePath: String, targetName: String, expected: Double) async throws {
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
