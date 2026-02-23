import ArgumentParser
import Foundation

/// Команда для обновления меток связи с документацией во всех поддерживаемых файлах проекта.
struct UpdateDocsLinks: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Обновление меток связи с документацией в файлах проекта")

    /// Основная логика поиска и обновления файлов.
    func run() async throws {
        try await Metrics.measure(step: "Update Docs Links") {
            print("🔗  Обновление меток связи с документацией...")

            let fileManager = FileManager.default
            let enumerator = fileManager.enumerator(atPath: ".")

            var filesToProcess: [String] = []

            while let file = enumerator?.nextObject() as? String {
                // Помечаем Swift файлы и YAML конфиги
                guard file.hasSuffix(".swift") || file.hasSuffix(".yml") else { continue }

                // Пропускаем исключенные папки
                if file.contains("Chat.xcodeproj") ||
                   file.contains("Resources") ||
                   file.contains("Design/Generated") ||
                   file.contains(".build") ||
                   file.contains("Tools/Scripts") {
                    continue
                }

                filesToProcess.append(file)
            }

            var filesUpdated = 0

            for file in filesToProcess {
                let fileURL = URL(fileURLWithPath: file)
                let content = try String(contentsOf: fileURL, encoding: .utf8)

                let docInfo = determineDocInfo(for: file, content: content)
                let docComment = formatDocComment(for: file, info: docInfo)

                if !content.contains("MARK: - Связь с документацией:") {
                    // Добавляем в начало файла
                    let newContent = docComment + "\n" + content
                    try newContent.write(to: fileURL, atomically: true, encoding: .utf8)
                    filesUpdated += 1
                } else if !content.contains(docComment) {
                    // Обновляем существующую метку
                    let lines = content.components(separatedBy: .newlines)
                    let updatedLines = lines.map { line -> String in
                        if line.contains("MARK: - Связь с документацией:") {
                            return docComment
                        }
                        return line
                    }

                    let newContent = updatedLines.joined(separator: "\n")
                    if newContent != content {
                        try newContent.write(to: fileURL, atomically: true, encoding: .utf8)
                        filesUpdated += 1
                    }
                }
            }

            print("✅  Обновление завершено. Обновлено файлов: \(filesUpdated)")
        }
    }

    private func formatDocComment(for filePath: String, info: (name: String, version: String)) -> String {
        let message = "MARK: - Связь с документацией: \(info.name) (Версия: \(info.version)). Статус: Синхронизировано."
        if filePath.hasSuffix(".yml") || filePath.hasSuffix(".yaml") {
            return "# \(message)"
        } else {
            return "// \(message)"
        }
    }

    private func determineDocInfo(for filePath: String, content: String) -> (name: String, version: String) {
        if filePath.contains("Models/LMStudio") || filePath.contains("Services/Chat") {
            return ("LM Studio", Versions.lmStudioDocs)
        } else if content.contains("import Factory") {
            return ("Factory", Versions.factory)
        } else if content.contains("import Pulse") {
            return ("Pulse", Versions.pulse)
        } else if filePath.contains("Design/") || filePath.contains("swiftgen.yml") {
            return ("SwiftGen", Versions.swiftgen)
        } else if filePath == "project.yml" {
            return ("XcodeGen", Versions.xcodegen)
        } else if filePath.contains("OpenAI") {
            return ("OpenAI", Versions.openAIDocs)
        } else if filePath.contains("Ollama") {
            return ("Ollama", Versions.ollamaDocs)
        } else if filePath.contains("Tests") {
            if content.contains("SnapshotTesting") {
                return ("SnapshotTesting", Versions.snapshotTesting)
            }
            return ("Тесты", Versions.swift)
        } else {
            return ("Документация проекта", "1.0.0")
        }
    }
}
