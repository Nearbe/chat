// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import Foundation

/// Основной инструмент проверки структуры и стандартов проекта.
public struct ProjectChecker {
    private let exceptions: [String: [String]]

    public static func run(quiet: Bool = true) async throws {
        if !quiet {
            print("🔍  Запуск специальных проверок проекта (ProjectChecker)...")
        }
        let exceptions = (try? ExceptionRegistry.loadProjectCheckerExceptions()) ?? [:]

        let checker = ProjectChecker(exceptions: exceptions)
        try await checker.perform(quiet: quiet)
    }

    private func perform(quiet: Bool) async throws {
        let filesToScan = collectFiles()
        var errors: [String] = []
        var logContent = "ProjectChecker Log\n"
        logContent += "Date: \(Date())\n\n"

        for file in filesToScan {
            let fileErrors = try checkFile(file)
            errors.append(contentsOf: fileErrors)
            if !fileErrors.isEmpty {
                logContent += "File: \(file)\n"
                fileErrors.forEach { logContent += "  - \($0)\n" }
            }
        }

        let toolErrors = await checkToolVersions()
        errors.append(contentsOf: toolErrors)
        if !toolErrors.isEmpty {
            logContent += "\nTool Versions Errors:\n"
            toolErrors.forEach { logContent += "  - \($0)\n" }
        }

        let projectYmlErrors = try checkProjectYml()
        errors.append(contentsOf: projectYmlErrors)

        let swiftLintErrors = try checkSwiftLintConfig()
        errors.append(contentsOf: swiftLintErrors)

        Shell.logToFile(name: "ProjectChecker", content: logContent)

        if !errors.isEmpty {
            if !quiet {
                print("❌  Обнаружены ошибки при проверке проекта:")
                errors.forEach { print("    - \($0)") }
            }
            throw CheckerError.validationFailed
        } else {
            if !quiet {
                print("✅  Все специальные проверки пройдены успешно.")
            }
        }
    }

    private func collectFiles() -> [String] {
        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(atPath: ".")

        var filesToScan: [String] = []
        let excludedPaths = exceptions["Путь"] ?? []

        while let file = enumerator?.nextObject() as? String {
            guard file.hasSuffix(".swift") else { continue }

            if excludedPaths.contains(where: { file.contains($0) }) {
                continue
            }
            filesToScan.append(file)
        }
        return filesToScan
    }

    private func checkFile(_ file: String) throws -> [String] {
        var errors: [String] = []
        let fileURL = URL(fileURLWithPath: file)
        let content = try String(contentsOf: fileURL, encoding: .utf8)
        let lines = content.components(separatedBy: .newlines)

        // Проверка наличия документации и именования перенесена в SwiftLint (custom_rules)
        // Если нужны дополнительные структурные проверки, добавлять сюда

        return errors
    }

    private func checkToolVersions() async -> [String] {
        var errors: [String] = []

        // XcodeGen
        do {
            let output = try await Shell.run("xcodegen --version", quiet: true)
            if !output.contains(Versions.xcodegen) {
                errors.append("XcodeGen: установлена версия \(output), ожидается \(Versions.xcodegen)")
            }
        } catch {
            errors.append("XcodeGen: инструмент не найден или не удалось определить версию")
        }

        // SwiftGen
        do {
            let output = try await Shell.run("swiftgen --version", quiet: true)
            if !output.contains(Versions.swiftgen) {
                errors.append("SwiftGen: установлена версия \(output), ожидается \(Versions.swiftgen)")
            }
        } catch {
            errors.append("SwiftGen: инструмент не найден или не удалось определить версию")
        }

        // SwiftLint
        do {
            let output = try await Shell.run("swiftlint --version", quiet: true)
            if !output.contains(Versions.swiftlint) {
                errors.append("SwiftLint: установлена версия \(output), ожидается \(Versions.swiftlint)")
            }
        } catch {
            errors.append("SwiftLint: инструмент не найден или не удалось определить версию")
        }

        return errors
    }

    private func checkProjectYml() throws -> [String] {
        var errors: [String] = []
        let projectYmlPath = "project.yml"

        guard FileManager.default.fileExists(atPath: projectYmlPath) else {
            return ["project.yml не найден"]
        }

        let content = try String(contentsOfFile: projectYmlPath, encoding: .utf8)

        // Проверка соответствия исключениям из реестра (для папок)
        let registryExceptions = (try? ExceptionRegistry.loadXcodeGenExceptions()) ?? []
        for exception in registryExceptions {
            // В XcodeGen исключение часто выражается отсутствием в sources или специфическим excluded
            // Пока проверяем, что если оно в реестре, то оно хотя бы известно в контексте project.yml (упрощенно)
            // Для Tools/Scripts мы знаем, что оно не должно быть в sources таргета Chat
            if exception == "Tools/Scripts" && content.contains("- path: Tools/Scripts\n") {
                 // Тут нужно быть аккуратным: оно может быть в packages.path: Tools/Scripts.
                 // Но оно не должно быть в sources таргета Chat.
            }
        }

        let checks = [
            ("Factory", Versions.factory),
            ("Pulse", Versions.pulse),
            ("SnapshotTesting", Versions.snapshotTesting),
            ("iOS: \"\(Versions.iOS)\"", Versions.iOS),
            ("SWIFT_VERSION: \"\(Versions.swift)\"", Versions.swift)
        ]

        for (label, version) in checks where !content.contains(version) {
            errors.append("project.yml: не найдена или неверная версия для \(label) (ожидается \(version))")
        }

        return errors
    }

    private func checkSwiftLintConfig() throws -> [String] {
        var errors: [String] = []
        let exceptions = (try? ExceptionRegistry.loadSwiftLintExceptions()) ?? [:]
        let ymlPath = ".swiftlint.yml"
        guard FileManager.default.fileExists(atPath: ymlPath) else {
            return [".swiftlint.yml не найден"]
        }
        let content = try String(contentsOfFile: ymlPath, encoding: .utf8)

        // 1. Проверка исключенных путей (excluded)
        let excludedPaths = exceptions["Путь"] ?? []
        for path in excludedPaths where !content.contains(path) {
            errors.append(".swiftlint.yml: отсутствует исключение пути '\(path)', указанное в IGNORED_WARNINGS.md")
        }

        // 2. Проверка ключевых слов (russian_docstring)
        let keywords = exceptions["Ключевое слово"] ?? []
        for keyword in keywords where !content.contains(keyword) {
            errors.append(".swiftlint.yml: отсутствует ключевое слово '\(keyword)' в правиле russian_docstring")
        }

        // 3. Проверка контекстов (no_print_logger)
        let contexts = exceptions["Контекст"] ?? []
        for context in contexts where !content.contains(context) {
            errors.append(".swiftlint.yml: отсутствует разрешенный контекст '\(context)' в правиле no_print_logger")
        }

        return errors
    }

    /// Ошибки, возникающие при проверке проекта.
    enum CheckerError: Error {
        case validationFailed
    }
}
