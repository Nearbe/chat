// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.

import Foundation

/// Сервис для парсинга SKILL.md файлов агентов.
/// Извлекает метаданные из frontmatter.
struct SkillFileParser {
    /// Результат парсинга frontmatter
    struct ParsedSkill {
        let name: String
        let description: String
        let version: String?
        let license: String?
        let author: String?
    }

    /// Парсит SKILL.md файл и извлекает frontmatter
    /// - Parameter path: Путь к файлу SKILL.md
    /// - Returns: Результат парсинга
    static func parse(at path: Path) throws -> ParsedSkill {
        let content = try String(contentsOfFile: path.string, encoding: .utf8)
        return parse(content: content)
    }

    /// Парсит контент SKILL.md
    /// - Parameter content: Текстовое содержимое файла
    /// - Returns: Результат парсинга
    static func parse(content: String) -> ParsedSkill {
        let name = extractName(from: content)
        let description = extractDescription(from: content)
        let version = extractVersion(from: content)
        let license = extractLicense(from: content)
        let author = extractAuthor(from: content)

        return ParsedSkill(
            name: name,
            description: description,
            version: version,
            license: license,
            author: author
        )
    }

    // MARK: - Приватные методы извлечения

    private static func extractName(from content: String) -> String {
        if let match = content.range(of: #"^---\s*\nname: (.+)$"#, options: .regularExpression) {
            let line = String(content[match])
            return line.components(separatedBy: "name: ").last?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        }
        return ""
    }

    private static func extractDescription(from content: String) -> String {
        if let match = content.range(of: #"^---\s*\nname:.+?\ndescription: (.+)$"#, options: .regularExpression) {
            let line = String(content[match])
            if let desc = line.components(separatedBy: "description: ").last {
                return desc.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return ""
    }

    private static func extractVersion(from content: String) -> String? {
        if let match = content.range(of: #"^---\s*\nname:.+?\ndescription:.+?\nversion: (.+)$"#, options: .regularExpression) {
            let line = String(content[match])
            return line.components(separatedBy: "version: ").last?.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return nil
    }

    private static func extractLicense(from content: String) -> String? {
        if content.contains("license:") {
            if let match = content.range(of: #"license: (.+)"#, options: .regularExpression) {
                let line = String(content[match])
                return line.components(separatedBy: "license: ").last?.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return nil
    }

    private static func extractAuthor(from content: String) -> String? {
        if content.contains("author:") {
            if let match = content.range(of: #"author: (.+)"#, options: .regularExpression) {
                let line = String(content[match])
                return line.components(separatedBy: "author: ").last?.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return nil
    }

    /// Конвертирует SKILL.md в формат Qwen
    /// - Parameters:
    ///   - content: Исходный контент
    ///   - agentName: Имя агента
    /// - Returns: Конвертированный контент
    static func convertToQwenFormat(_ content: String, agentName: String) -> String {
        // Извлекаем frontmatter
        guard let frontmatterMatch = content.range(of: #"^---\n[\s\S]*?\n---"#, options: .regularExpression) else {
            return content
        }

        let frontmatter = String(content[frontmatterMatch])
        let body = String(content[frontmatterMatch.upperBound ...])

        // Конвертируем name в snake_case для названия навыка
        let skillName = agentName.replacingOccurrences(of: "-", with: "_")

        // Модифицируем frontmatter
        var newFrontmatter = frontmatter.replacingOccurrences(
            of: "name: .*",
            with: "name: \(skillName)",
            options: .regularExpression
        )

        // Добавляем license и author если нет
        if !newFrontmatter.contains("license:") {
            newFrontmatter = newFrontmatter.replacingOccurrences(
                of: "---\n",
                with: "---\nlicense: MIT\nauthor: Chat Project\n"
            )
        }

        return newFrontmatter + body
    }
}
