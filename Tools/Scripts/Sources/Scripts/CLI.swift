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
            ConfigureSudo.self
        ],
        defaultSubcommand: Check.self
    )

    struct Project {
        static let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }
}
