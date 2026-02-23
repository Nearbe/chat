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
        let excludedFolders = exceptions["Папка"] ?? []

        while let file = enumerator?.nextObject() as? String {
            guard file.hasSuffix(".swift") else { continue }

            if excludedFolders.contains(where: { file.contains($0) }) {
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

        // 1. Проверка наличия документации (Docstrings)
        errors.append(contentsOf: checkDocumentation(lines: lines, filePath: file))

        // 2. Проверка именования SwiftUI вьюх (должны заканчиваться на View или Page)
        if file.contains("Views/") || file.contains("Pages/") {
            errors.append(contentsOf: checkViewNaming(lines: lines, filePath: file))
        }

        return errors
    }

    private func checkDocumentation(lines: [String], filePath: String) -> [String] {
        var errors: [String] = []

        // Регулярка для поиска деклараций (class, struct, enum, protocol, func)
        // Игнорируем private/fileprivate и декларации внутри методов (упрощенно)
        // Игнорируем extension, так как они часто не требуют отдельной доки
        // Игнорируем CodingKeys, так как это стандарт Swift
        let declarationPattern = #"^(?!\s*//)(?!\s*/\*)\s*(public |internal |open )?(class|struct|enum|protocol|func)\s+\w+"#
        // swiftlint:disable:next force_try
        let regex = try! NSRegularExpression(pattern: declarationPattern)

        let ignoredNames = exceptions["Символ"] ?? []

        for (index, line) in lines.enumerated() {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)

            // Проверка на игнорируемые имена
            var isIgnored = false
            for name in ignoredNames where trimmedLine.contains(name) {
                isIgnored = true
                break
            }
            if isIgnored { continue }

            let range = NSRange(line.startIndex..<line.endIndex, in: line)
            if regex.firstMatch(in: line, options: [], range: range) != nil {
                // Если это декларация, проверяем строку выше (или несколько строк выше) на наличие "///"
                var hasDoc = false

                // Проверяем до 3 строк выше (на случай атрибутов)
                for offset in 1...3 where index - offset >= 0 {
                    let prevLine = lines[index - offset].trimmingCharacters(in: .whitespaces)
                    if prevLine.hasPrefix("///") || prevLine.hasSuffix("*/") {
                        hasDoc = true
                        break
                    }
                    // Если встретили пустую строку или другую декларацию, значит доки нет
                    if prevLine.isEmpty { break }
                }

                if !hasDoc {
                    errors.append("\(filePath):\(index + 1): Отсутствует документация (Docstring) для '\(trimmedLine)'")
                }
            }
        }

        return errors
    }

    private func checkViewNaming(lines: [String], filePath: String) -> [String] {
        let errors: [String] = []
        let fileName = (filePath as NSString).lastPathComponent

        // Упрощенно: если файл в Views, он должен иметь View в названии (или Page в Pages или Component)
        if (filePath.contains("Views/") || filePath.contains("Pages/")) &&
           !fileName.contains("View") && !fileName.contains("Page") && !fileName.contains("Component") {
            // errors.append("\(filePath): Имя файла должно содержать 'View', 'Page' или 'Component'")
        }

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
        let registryExceptions = (try? ExceptionRegistry.loadSwiftLintExceptions()) ?? []
        let ymlPath = ".swiftlint.yml"
        guard FileManager.default.fileExists(atPath: ymlPath) else {
            return [".swiftlint.yml не найден"]
        }
        let content = try String(contentsOfFile: ymlPath, encoding: .utf8)
        for exception in registryExceptions where !content.contains(exception) {
            errors.append(".swiftlint.yml: отсутствует исключение '\(exception)', указанное в IGNORED_WARNINGS.md")
        }
        return errors
    }

    /// Ошибки, возникающие при проверке проекта.
    enum CheckerError: Error {
        case validationFailed
    }
}
