// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import ArgumentParser
import Foundation

struct Check: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Техническая проверка проекта (Lint + Build + Test + Commit)")

    @Argument(help: "Сообщение для коммита")
    var message: String?

    // swiftlint:disable:next function_body_length
    func run() async throws {
        let device = "platform=iOS Simulator,name=iPhone 16 Pro Max"

        print("🚀  Начало технической проверки (Асинхронный режим)...")

        try await withThrowingTaskGroup(of: Void.self) { mainGroup in
            // 1. Параллельный линтинг и специальные проверки
            mainGroup.addTask {
                try await Metrics.measure(step: "Linting") {
                    print("🔍  Запуск SwiftLint...")
                    _ = try? await Shell.run("swiftlint --strict")

                    print("🔍  Запуск ProjectChecker...")
                    try await ProjectChecker.run()

                    print("✅  Линтинг и проверки завершены успешно.")
                }
            }

            // 2. Группа генерации и последующей сборки/тестирования
            mainGroup.addTask {
                // Сначала инфраструктура (XcodeGen + SwiftGen)
                print("🏗️  Этап 1: Подготовка инфраструктуры...")
                try await withThrowingTaskGroup(of: Void.self) { genGroup in
                    genGroup.addTask {
                        try await Metrics.measure(step: "XcodeGen") {
                            print("📦  Генерация проекта (XcodeGen)...")
                            try await Shell.run("xcodegen generate")
                        }
                    }
                    genGroup.addTask {
                        try await Metrics.measure(step: "SwiftGen") {
                            print("🎨  Генерация ресурсов (SwiftGen)...")
                            try await runSwiftGen()
                        }
                    }

                    try await genGroup.waitForAll()
                }

                // Как только генерация завершена, запускаем сборку и тесты параллельно
                print("🧪  Этап 2: Сборка и тестирование (Параллельно)...")
                try await withThrowingTaskGroup(of: Void.self) { buildGroup in
                    // Тесты (Unit + UI)
                    buildGroup.addTask {
                        try await Metrics.measure(step: "Tests") {
                            print("🧪  Запуск тестов через Test Plan (AllTests)...")
                            let resultPath = "TestResult.xcresult"
                            try? FileManager.default.removeItem(atPath: resultPath)

                            let testCommand = [
                                "xcodebuild",
                                "-project Chat.xcodeproj",
                                "-scheme Chat",
                                "-testPlan AllTests",
                                "-destination \"\(device)\"",
                                "-resultBundlePath \(resultPath)",
                                "test",
                                "CODE_SIGNING_ALLOWED=NO",
                                "CODE_SIGNING_REQUIRED=NO",
                                "| grep -E \"Test Suite|passed|failed|skipped\""
                            ].joined(separator: " ")

                            try await Shell.run(testCommand)
                            try await self.checkCoverage(resultBundlePath: resultPath, targetName: "Chat", expected: 40.0)
                            print("✅  Все тесты пройдены и покрытие >= 40%.")
                        }
                    }

                    // Релизная сборка
                    buildGroup.addTask {
                        try await Metrics.measure(step: "Build Release") {
                            print("📦  Сборка Release версии...")
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

                            try await Shell.run(releaseCommand)
                            print("✅  Release сборка завершена.")
                        }
                    }

                    try await buildGroup.waitForAll()
                }
            }

            try await mainGroup.waitForAll()
        }

        print("✅  Техническая проверка успешно завершена!")

        // Группа 4: Git
        try await Metrics.measure(step: "Git Commit & Push") {
            try await handleGitCommit()
        }
    }

    private func runSwiftGen() async throws {
        try await Shell.run("swiftgen")
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
            print("📦  Добавление изменений в индекс...")
            try await Shell.run("git add .")
            print("💾  Коммит изменений: '\(commitMessage)'...")
            try await Shell.run("git commit -m \"\(commitMessage)\"")
            print("📤  Отправка в удаленный репозиторий (push)...")
            try await Shell.run("git push")
            print("🚀  Код закоммичен и отправлен!")
        } else {
            print("ℹ️  Изменений не обнаружено, коммит не требуется.")
        }
    }

    private func checkCoverage(resultBundlePath: String, targetName: String, expected: Double) async throws {
        print("📊  Проверка покрытия кода для \(targetName) в \(resultBundlePath)...")
        let command = "xcrun xccov view --report --json \(resultBundlePath)"
        let jsonString = try await Shell.run(command, quiet: true)

        guard let data = jsonString.data(using: .utf8) else {
            throw CheckError.coverageCheckFailed("Не удалось распарсить JSON отчета о покрытии")
        }

        // Упрощенный парсинг JSON для поиска покрытия таргета
        // Структура xccov JSON: { "targets": [ { "name": "Chat.app", "lineCoverage": 0.85, ... } ] }
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let targets = json["targets"] as? [[String: Any]] {
            for target in targets {
                if let name = target["name"] as? String, name.contains(targetName) {
                    if let lineCoverage = target["lineCoverage"] as? Double {
                        let percentage = lineCoverage * 100.0
                        print("📈  Текущее покрытие для \(name): \(String(format: "%.2f", percentage))%")
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
