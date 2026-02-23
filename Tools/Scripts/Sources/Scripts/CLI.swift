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

    struct Project {
        static let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }
}
