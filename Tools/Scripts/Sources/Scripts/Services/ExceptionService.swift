// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.

import Foundation

/// Сервис для работы с исключениями и предупреждениями.
enum ExceptionService {
    /// Загружает список системных предупреждений.
    static func loadSystemWarnings() throws -> [String] {
        let content = try loadContent()
        let section = try extractSection(from: content, header: "## 🛠️ Системные предупреждения (Xcode/Build)")
        return parseTable(section, patternColumnIndex: 2)
    }

    /// Загружает исключения для ProjectChecker.
    static func loadProjectCheckerExceptions() throws -> [String: [String]] {
        let content = try loadContent()
        var result: [String: [String]] = [:]

        let sections = [
            ("Путь", "### 📂 Исключенные пути"),
            ("Ключевое слово", "### 🔑 Технические ключевые слова"),
            ("Контекст", "### 📝 Разрешенные контексты print()")
        ]

        for (type, header) in sections {
            let sectionContent = try extractSection(from: content, header: header)
            result[type] = parseTable(sectionContent, patternColumnIndex: 2)
        }

        return result
    }

    /// Загружает исключения для SwiftLint.
    static func loadSwiftLintExceptions() throws -> [String: [String]] {
        return try loadProjectCheckerExceptions()
    }

    /// Загружает исключения XcodeGen.
    static func loadXcodeGenExceptions() throws -> [String] {
        let content = try loadContent()
        let section = try extractSection(from: content, header: "## 🏗️ Исключения XcodeGen (project.yml)")
        return parseTable(section, patternColumnIndex: 3)
    }

    // MARK: - Private

    private static func loadContent() throws -> String {
        let path = "Docs/IGNORED_WARNINGS.md"
        return try String(contentsOfFile: path, encoding: .utf8)
    }

    private static func extractSection(from content: String, header: String) throws -> String {
        let lines = content.components(separatedBy: .newlines)
        guard let startIndex = lines.firstIndex(where: {
            $0.contains(header)
        }) else {
            return ""
        }

        var sectionLines: [String] = []
        for index in (startIndex + 1) ..< lines.count {
            let line = lines[index]
            if line.hasPrefix("## ") || line.hasPrefix("### ") {
                break
            }
            sectionLines.append(line)
        }
        return sectionLines.joined(separator: "\n")
    }

    private static func parseTable(_ content: String, patternColumnIndex: Int) -> [String] {
        let lines = content.components(separatedBy: .newlines)
        var patterns: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.hasPrefix("|") && !trimmed.contains("---") && !trimmed.contains(" № ") && !trimmed.contains("| № |") else {
                continue
            }

            let columns = trimmed.components(separatedBy: "|")
            if columns.count > patternColumnIndex {
                let pattern = columns[patternColumnIndex].trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "`", with: "")
                if !pattern.isEmpty {
                    patterns.append(pattern)
                }
            }
        }
        return patterns
    }
}

/// Alias для обратной совместимости.
typealias ExceptionRegistry = ExceptionService
