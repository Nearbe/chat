// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import Foundation

/// Реестр исключений, загружаемый из Docs/IGNORED_WARNINGS.md
public enum ExceptionRegistry {
    /// Загружает список системных предупреждений, которые можно игнорировать
    public static func loadSystemWarnings() throws -> [String] {
        let content = try loadContent()
        let section = try extractSection(from: content, header: "## 🛠️ Системные предупреждения (Xcode/Build)")
        return parseTable(section, patternColumnIndex: 2) // Колонки: №(1), Паттерн(2), Причина(3), Обоснование(4)
    }

    /// Загружает исключения для ProjectChecker, сгруппированные по типам
    public static func loadProjectCheckerExceptions() throws -> [String: [String]] {
        let content = try loadContent()
        var result: [String: [String]] = [:]

        // Парсим каждую таблицу отдельно для ProjectChecker и SwiftLint
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

    /// Загружает исключения для SwiftLint, используя логику ProjectChecker
    public static func loadSwiftLintExceptions() throws -> [String: [String]] {
        return try loadProjectCheckerExceptions()
    }

    /// Загружает список исключений XcodeGen
    public static func loadXcodeGenExceptions() throws -> [String] {
        let content = try loadContent()
        let section = try extractSection(from: content, header: "## 🏗️ Исключения XcodeGen (project.yml)")
        return parseTable(section, patternColumnIndex: 3) // Колонки: №(1), Тип(2), Паттерн(3), Причина(4), Обоснование(5)
    }

    private static func loadContent() throws -> String {
        let path = "Docs/IGNORED_WARNINGS.md"
        return try String(contentsOfFile: path, encoding: .utf8)
    }

    private static func extractSection(from content: String, header: String) throws -> String {
        let lines = content.components(separatedBy: .newlines)
        guard let startIndex = lines.firstIndex(where: { $0.contains(header) }) else {
            return ""
        }

        var sectionLines: [String] = []
        for index in (startIndex + 1)..<lines.count {
            let line = lines[index]
            // Секция заканчивается, если встретили заголовок такого же или высшего уровня
            if line.hasPrefix("## ") || line.hasPrefix("### ") { break }
            sectionLines.append(line)
        }
        return sectionLines.joined(separator: "\n")
    }

    private static func parseTable(_ content: String, patternColumnIndex: Int) -> [String] {
        let lines = content.components(separatedBy: .newlines)
        var patterns: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.hasPrefix("|") && !trimmed.contains("---") && !trimmed.contains(" № ") && !trimmed.contains("| № |") else { continue }

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

    private static func parseTableWithTypes(_ content: String) -> [(type: String, pattern: String)] {
        let lines = content.components(separatedBy: .newlines)
        var result: [(type: String, pattern: String)] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.hasPrefix("|") && !trimmed.contains("---") && !trimmed.contains(" № ") && !trimmed.contains("| № |") else { continue }

            let columns = trimmed.components(separatedBy: "|")
            if columns.count >= 4 {
                let type = columns[2].trimmingCharacters(in: .whitespaces)
                let pattern = columns[3].trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "`", with: "")
                if !type.isEmpty && !pattern.isEmpty {
                    result.append((type, pattern))
                }
            }
        }
        return result
    }
}
