// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.

import Foundation

/// Сервис для регистрации агентов в ~/.qwen/skills/
/// Отвечает за копирование и конвертацию SKILL.md файлов.
struct SkillRegistrar {
    /// Путь к директории навыков Qwen
    static var qwenSkillsPath: Path {
        Path.homeDirectory + ".qwen/skills"
    }

    /// Регистрирует агента в ~/.qwen/skills/
    /// - Parameters:
    ///   - name: Имя агента
    ///   - sourcePath: Путь к исходному SKILL.md
    /// - Returns: Путь к зарегистрированному файлу
    @discardableResult
    static func register(name: String, from sourcePath: Path) throws -> Path {
        let targetPath = qwenSkillsPath + name

        // Создаём папку агента
        try ? FileManager.default.createDirectory(
            atPath: targetPath.string,
            withIntermediateDirectories: true
        )

        // Читаем и конвертируем SKILL.md
        let skillContent = try String(contentsOfFile: sourcePath.string, encoding: .utf8)
        let convertedContent = SkillFileParser.convertToQwenFormat(skillContent, agentName: name)

        // Записываем
        let targetFile = targetPath + "SKILL.md"
        try convertedContent.write(toFile: targetFile.string, atomically: true, encoding: .utf8)

        print("  ✓ Зарегистрирован: \(name)")
        return targetFile
    }

    /// Регистрирует всех агентов из папки Agents/
    /// - Parameter agentsPath: Путь к папке Agents в проекте
    /// - Returns: Количество зарегистрированных агентов
    static func registerAll(from agentsPath: Path) throws -> Int {
        // Создаём директорию ~/.qwen/skills/ если нет
        try ? FileManager.default.createDirectory(
            atPath: qwenSkillsPath.string,
            withIntermediateDirectories: true
        )

        let agentNames = try AgentScanner.scan(agentsPath: agentsPath)
        var registeredCount = 0

        for agentName in agentNames {
            guard let skillPath = AgentScanner.skillFilePath(for: agentName, in: agentsPath) else {
                print("  ⏭️  Пропущен: \(agentName) (нет SKILL.md)")
                continue
            }

            try register(name: agentName, from: skillPath)
            registeredCount += 1
        }

        return registeredCount
    }
}
