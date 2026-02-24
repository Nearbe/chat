// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import ArgumentParser
import Foundation

/// Команда для начальной настройки окружения и инфраструктуры проекта.
struct Setup: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Подготовка проекта к работе (XcodeGen + SwiftGen)"
    )

    func run() async throws {
        print("🏗️  Подготовка проекта...")

        try await Metrics.measure(step: "Ensure Dependencies") {
            try await DependencyService.ensureDependencies()
        }

        try await Metrics.measure(step: "Setup Assets") {
            try await AssetSetupService.setup()
        }

        try await Metrics.measure(step: "XcodeGen") {
            print("🏗️  Генерация Xcode проекта (XcodeGen)...")
            try await Shell.run("xcodegen generate")
        }

        try await Metrics.measure(step: "SwiftGen") {
            print("🎨 Генерация ресурсов (SwiftGen)...")
            try await SwiftGenService.run()
        }

        try await Metrics.measure(step: "Register Agents") {
            print("🤖 Регистрация агентов в Qwen...")
            try await registerAgents()
        }

        print("✅ Проект готов к работе!")
    }

    private func registerAgents() async throws {
        let agentsPath = Path.currentDirectory + "Agents"
        guard FileManager.default.fileExists(atPath: agentsPath.string) else {
            return
        }

        let qwenSkillsPath = Path.homeDirectory + ".qwen/skills"
        try? FileManager.default.createDirectory(
            atPath: qwenSkillsPath.string,
            withIntermediateDirectories: true
        )

        let agentFolders = try FileManager.default.contentsOfDirectory(
            atPath: agentsPath.string
        ).filter {
            $0 != "README.md" && $0 != "workspace"
        }

        for agentName in agentFolders {
            let agentPath = agentsPath + agentName
            let skillFile = agentPath + "SKILL.md"

            guard FileManager.default.fileExists(atPath: skillFile.string) else {
                continue
            }

            let targetPath = qwenSkillsPath + agentName
            try? FileManager.default.createDirectory(
                atPath: targetPath.string,
                withIntermediateDirectories: true
            )

            let skillContent = try String(contentsOfFile: skillFile.string, encoding: .utf8)
            let convertedContent = convertToQwenFormat(skillContent, agentName: agentName)
            let targetFile = targetPath + "SKILL.md"
            try convertedContent.write(toFile: targetFile.string, atomically: true, encoding: .utf8)

            print("  ✓ \(agentName)")
        }
    }

    private func convertToQwenFormat(_ content: String, agentName: String) -> String {
        guard let frontmatterMatch = content.range(of: #"^---\n[\s\S]*?\n---"#, options: .regularExpression) else {
            return content
        }

        let frontmatter = String(content[frontmatterMatch])
        let body = String(content[frontmatterMatch.upperBound...])

        let skillName = agentName.replacingOccurrences(of: "-", with: "_")

        var newFrontmatter = frontmatter.replacingOccurrences(of: "name: .*", with: "name: \(skillName)", options: .regularExpression)

        if !newFrontmatter.contains("license:") {
            newFrontmatter = newFrontmatter.replacingOccurrences(
                of: "---\n",
                with: "---\nlicense: MIT\nauthor: Chat Project\n"
            )
        }

        return newFrontmatter + body
    }
}
