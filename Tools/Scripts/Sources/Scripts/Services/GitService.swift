// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import Foundation

/// Сервис для работы с git.
enum GitService {
    /// Файлы для игнорирования при проверке изменений.
    private static let ignoredFiles: Set<String> = [
        "metrics.csv",
        "Logs/",
        ".xcresult",
        "TestResult.xcresult",
        ".idea/"
    ]

    /// Получает список изменённых файлов относительно последнего коммита.
    static func getChangedFiles() async throws -> ChangedFilesInfo {
        let output = try await Shell.run("git diff --name-only HEAD", quiet: true)

        let files = output.components(separatedBy: .newlines)
            .filter { file in
                guard !file.isEmpty else { return false }
                return !isIgnored(file: file)
            }

        return ChangedFilesInfo(files: files, hasChanges: !files.isEmpty)
    }

    /// Проверяет, нужно ли запускать SwiftLint.
    static func needsSwiftLint(files: [String]) -> Bool {
        files.contains { $0.hasSuffix(".swift") }
    }

    /// Проверяет, нужно ли запускать XcodeGen.
    static func needsXcodeGen(files: [String]) -> Bool {
        files.contains { $0 == "project.yml" || $0.hasPrefix("Tools/") }
    }

    /// Проверяет, нужно ли запускать SwiftGen.
    static func needsSwiftGen(files: [String]) -> Bool {
        let designFiles = files.filter { $0.hasPrefix("Design/") || $0.hasPrefix("Resources/") }
        return !designFiles.isEmpty || files.contains { $0 == "swiftgen.yml" }
    }

    /// Проверяет, нужно ли запускать Unit-тесты.
    static func needsUnitTests(files: [String]) -> Bool {
        let testFiles = files.filter {
            $0.hasPrefix("ChatTests/") || $0.hasPrefix("Chat/") ||
            $0.hasPrefix("Features/") || $0.hasPrefix("Services/") ||
            $0.hasPrefix("Models/") || $0.hasPrefix("Core/") ||
            $0.hasPrefix("Data/")
        }
        return !testFiles.isEmpty
    }

    /// Проверяет, нужно ли запускать UI-тесты.
    static func needsUITests(files: [String]) -> Bool {
        let uiTestFiles = files.filter {
            $0.hasPrefix("ChatUITests/") || $0.hasPrefix("Features/")
        }
        return !uiTestFiles.isEmpty
    }

    // MARK: - Private

    private static func isIgnored(file: String) -> Bool {
        ignoredFiles.contains { pattern in
            if pattern.hasSuffix("/") {
                return file.hasPrefix(pattern)
            } else {
                return file == pattern || file.hasPrefix(pattern)
            }
        }
    }
}
