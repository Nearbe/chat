// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import ArgumentParser
import Foundation

@main
struct Scripts: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Утилита для автоматизации разработки проекта Chat",
        subcommands: [
            Setup.self,
            Check.self,
            Ship.self,
            DownloadDocs.self,
            UpdateDocsLinks.self,
            ConfigureSudo.self
        ],
        defaultSubcommand: Check.self
    )

    static func main() async {
        // Устанавливаем рабочую директорию в корень проекта перед выполнением любых команд
        let root = Project.root.path
        if !FileManager.default.changeCurrentDirectoryPath(root) {
            print("⚠️  Не удалось изменить рабочую директорию на \(root)")
        }

        Metrics.start()
        do {
            var command = try Scripts.parseAsRoot()
            if var asyncCommand = command as? AsyncParsableCommand {
                try await asyncCommand.run()
            } else {
                try command.run()
            }
            Metrics.logTotalTime()
        } catch {
            Metrics.logTotalTime()
            Scripts.exit(withError: error)
        }
    }

    enum Project {
        static let root: URL = {
            // Пытаемся найти корень проекта, поднимаясь вверх от папки этого файла
            // #filePath указывает на полный путь к этому файлу во время компиляции
            let filePath = #filePath
            let currentFile = URL(fileURLWithPath: filePath)
            var current = currentFile.deletingLastPathComponent()

            while current.path != "/" {
                let projectYml = current.appendingPathComponent("project.yml")
                if FileManager.default.fileExists(atPath: projectYml.path) {
                    return current
                }
                current = current.deletingLastPathComponent()
            }

            // Если не нашли (например, бинарник перенесен), используем CWD
            return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        }()
    }
}
