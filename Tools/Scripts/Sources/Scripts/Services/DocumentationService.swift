// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.

import Foundation

/// Сервис для управления документацией и ссылками на неё.
enum DocumentationService {
    /// Обновляет метки документации во всех файлах проекта.
    static func updateDocLinks() async throws {
        let files = try findFilesToProcess()
        var filesUpdated = 0

        for file in files {
            let fileURL = URL(fileURLWithPath: file)
            let content = try String(contentsOf: fileURL, encoding: .utf8)

            let docInfo = determineDocInfo(for: file, content: content)
            let docComment = formatDocComment(for: file, info: docInfo)

            if updateFile(fileURL: fileURL, content: content, docComment: docComment) {
                filesUpdated += 1
            }
        }

        print("✅  Обновление завершено. Обновлено файлов: \(filesUpdated)")
    }

    // MARK: - Private

    private static func findFilesToProcess() throws -> [String] {
        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(atPath: ".")
        var files: [String] = []

        while let file = enumerator?.nextObject() as?String {
            guard file.hasSuffix(".swift") || file.hasSuffix(".yml") else {
                continue
            }

            if shouldSkip(file: file) {
                continue
            }
            files.append(file)
        }

        return files
    }

    private static func shouldSkip(file: String) -> Bool {
        let skipPatterns = [
            "Chat.xcodeproj", "Resources", "Design/Generated",
            ".build", "Tools/Scripts"
        ]
        return skipPatterns.contains {
            file.contains($0)
        }
    }

    private static func formatDocComment(for filePath: String, info: (name: String, version: String)) -> String {
        let message = "MARK: - Связь с документацией: \(info.name) (Версия: \(info.version)). Статус: Синхронизировано."
        if filePath.hasSuffix(".yml") || filePath.hasSuffix(".yaml") {
            return "# \(message)"
        }
        return "// \(message)"
    }

    private static func determineDocInfo(for filePath: String, content: String) -> (name: String, version: String) {
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
        }
        return ("Документация проекта", "1.0.0")
    }

    private static func updateFile(fileURL: URL, content: String, docComment: String) -> Bool {
        if !content.contains("MARK: - Связь с документацией:") {
            let newContent = docComment + "\n" + content
            try? newContent.write(to: fileURL, atomically: true, encoding: .utf8)
            return true
        }

        if !content.contains(docComment) {
            let lines = content.components(separatedBy: .newlines)
            let updatedLines = lines.map {
                line -> String in
                if line.contains("MARK: - Связь с документацией:") {
                    return docComment
                }
                return line
            }
            let newContent = updatedLines.joined(separator: "\n")
            if newContent != content {
                try? newContent.write(to: fileURL, atomically: true, encoding: .utf8)
                return true
            }
        }

        return false
    }
}
