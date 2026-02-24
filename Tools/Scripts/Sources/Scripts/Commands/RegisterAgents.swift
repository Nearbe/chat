// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.

import ArgumentParser
import Foundation

/// Команда для регистрации агентов из папки Agents/ в системе навыков Qwen.
struct RegisterAgents: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Регистрация агентов в ~/.qwen/skills/",
        discussion: """
                    Сканирует папку Agents/ и создаёт навыки в ~/.qwen/skills/.
                    Каждый агент должен иметь файл SKILL.md с frontmatter.
                    """
    )

    func run() async throws {
        print("🤖 Регистрация агентов...")

        let agentsPath = Path.currentDirectory + "Agents"
        guard FileManager.default.fileExists(atPath: agentsPath.string) else {
            print("⚠️  Папка Agents/ не найдена")
            return
        }

        let qwenSkillsPath = Path.homeDirectory + ".qwen/skills"

        // Создаём директорию ~/.qwen/skills/ если нет
        try ? FileManager.default.createDirectory(
            atPath: qwenSkillsPath.string,
            withIntermediateDirectories: true
        )

        // Сканируем все папки агентов
        let agentFolders = try FileManager.default.contentsOfDirectory(
            atPath: agentsPath.string
        ).filter {
            $0 != "README.md" && $0 != "workspace"
        }

        var registeredCount = 0

        for agentName in agentFolders {
            let agentPath = agentsPath + agentName
            let skillFile = agentPath + "SKILL.md"

            guard FileManager.default.fileExists(atPath: skillFile.string) else {
                print("  ⏭️  Пропущен: \(agentName) (нет SKILL.md)")
                continue
            }

            // Конвертируем и копируем
            try await registerAgent(name: agentName, from: skillFile, to: qwenSkillsPath)
            registeredCount += 1
        }

        print("✅ Зарегистрировано агентов: \(registeredCount)")
    }

    private func registerAgent(name: String, from sourcePath: Path, to qwenPath: Path) async throws {
        let targetPath = qwenPath + name

        // Создаём папку агента
        try ? FileManager.default.createDirectory(
            atPath: targetPath.string,
            withIntermediateDirectories: true
        )

        // Читаем SKILL.md
        let skillContent = try String(contentsOfFile: sourcePath.string, encoding: .utf8)

        // Конвертируем в формат Qwen
        let convertedContent = convertToQwenFormat(skillContent, agentName: name)

        // Записываем
        let targetFile = targetPath + "SKILL.md"
        try convertedContent.write(toFile: targetFile.string, atomically: true, encoding: .utf8)

        print("  ✓ Зарегистрирован: \(name)")
    }

    private func convertToQwenFormat(_ content: String, agentName: String) -> String {
        // Извлекаем frontmatter
        guard let frontmatterMatch = content.range(of: #"^---\n[\s\S]*?\n---"#, options: .regularExpression) else {
            return content
        }

        let frontmatter = String(content[frontmatterMatch])
        let body = String(content[frontmatterMatch.upperBound ...])

        // Конвертируем name в snake_case для названия навыка
        let skillName = agentName.replacingOccurrences(of: "-", with: "_")

        // Модифицируем frontmatter - убираем version и добавляем лицензию
        var newFrontmatter = frontmatter.replacingOccurrences(of: "name: .*", with: "name: \(skillName)", options: .regularExpression)

        // Если нет license и author - добавляем
        if !newFrontmatter.contains("license:") {
            newFrontmatter = newFrontmatter.replacingOccurrences(
                of: "---\n",
                with: "---\nlicense: MIT\nauthor: Chat Project\n"
            )
        }

        return newFrontmatter + body
    }
}

// MARK: - Path Helper

struct Path: ExpressibleByStringLiteral {
    let string: String

    init(_ path: String) {
        self.string = path
    }

    init(stringLiteral: String) {
        self.string = stringLiteral
    }

    static var currentDirectory: Path {
        Path(FileManager.default.currentDirectoryPath)
    }

    static var homeDirectory: Path {
        Path(NSHomeDirectory())
    }

    static func +(lhs: Path, rhs: String) -> Path {
        Path(lhs.string + "/" + rhs)
    }
}
