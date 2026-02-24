// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.

import Foundation

/// Сервис для скачивания документации.
enum DocDownloadService {
    /// Скачивает всю документацию параллельно.
    static func downloadAll() async throws {
        try await withThrowingTaskGroup(of: Void.self) {
            group in
            group.addTask {
                try await downloadLMStudio()
            }
            group.addTask {
                try await downloadOpenAI()
            }
            group.addTask {
                try await downloadFactory()
            }
            group.addTask {
                try await downloadPulse()
            }
            group.addTask {
                try await downloadOllama()
            }
            group.addTask {
                try await downloadCodegen()
            }
            try await group.waitForAll()
        }
    }

    // MARK: - LM Studio

    private static func downloadLMStudio() async throws {
        let files: [String: String] = [
            "0_app/0_root/index.md": "index.md",
            "1_developer/index.md": "developer/index.md",
            "1_developer/api-changelog.md": "developer/api-changelog.md",
            "1_developer/2_rest/index.md": "developer/rest/index.md",
            "1_developer/2_rest/quickstart.md": "developer/rest/quickstart.md",
            "1_developer/2_rest/endpoints.md": "developer/rest/endpoints.md",
            "1_developer/2_rest/chat.md": "developer/rest/chat.md",
            "1_developer/2_rest/streaming-events.md": "developer/rest/streaming-events.md",
            "1_developer/2_rest/load.md": "developer/rest/load.md",
            "1_developer/2_rest/unload.md": "developer/rest/unload.md",
            "1_developer/2_rest/list.md": "developer/rest/list.md",
            "1_developer/2_rest/download.md": "developer/rest/download.md",
            "1_developer/2_rest/download-status.md": "developer/rest/download-status.md",
            "1_developer/3_openai-compat/index.md": "developer/openai-compat/index.md",
            "1_developer/3_openai-compat/chat-completions.md": "developer/openai-compat/chat-completions.md",
            "1_developer/3_openai-compat/models.md": "developer/openai-compat/models.md",
            "1_developer/3_openai-compat/tools.md": "developer/openai-compat/tools.md",
            "1_developer/3_openai-compat/structured-output.md": "developer/openai-compat/structured-output.md",
            "3_cli/index.md": "cli/index.md"
        ]
        await download(baseURL: "https://raw.githubusercontent.com/lmstudio-ai/docs/\(Versions.lmStudioDocs)", files: files, destinationDir: "Docs/LMStudio")
    }

    // MARK: - OpenAI

    private static func downloadOpenAI() async throws {
        await download(
            baseURL: "https://raw.githubusercontent.com/openai/openai-openapi/\(Versions.openAIDocs)",
            files: ["openapi.yaml": "openapi.yaml"],
            destinationDir: "Docs/OpenAI"
        )
    }

    // MARK: - Factory

    private static func downloadFactory() async throws {
        await download(
            baseURL: "https://raw.githubusercontent.com/hmlongco/Factory/\(Versions.factory)",
            files: ["README.md": "README.md"],
            destinationDir: "Docs/Factory"
        )
    }

    // MARK: - Pulse

    private static func downloadPulse() async throws {
        await download(
            baseURL: "https://raw.githubusercontent.com/kean/Pulse/\(Versions.pulse)",
            files: ["README.md": "README.md"],
            destinationDir: "Docs/Pulse"
        )
    }

    // MARK: - Ollama

    private static func downloadOllama() async throws {
        await download(
            baseURL: "https://raw.githubusercontent.com/ollama/ollama/\(Versions.ollamaDocs)",
            files: ["docs/api.md": "api.md"],
            destinationDir: "Docs/Ollama"
        )
    }

    // MARK: - Codegen

    private static func downloadCodegen() async throws {
        await download(
            baseURL: "https://raw.githubusercontent.com/yonaskolb/XcodeGen/\(Versions.xcodegen)",
            files: ["README.md": "README.md"],
            destinationDir: "Docs/XcodeGen"
        )
    }

    // MARK: - Private

    private static func download(baseURL: String, files: [String: String], destinationDir: String) async {
        do {
            try FileManager.default.createDirectory(atPath: destinationDir, withIntermediateDirectories: true)

            for (sourcePath, destPath) in files {
                let url = "\(baseURL)/\(sourcePath)"
                let destination = "\(destinationDir)/\(destPath)"

                guard let remoteURL = URL(string: url) else {
                    continue
                }

                let (data, _) = try await URLSession.shared.data(from: remoteURL)
                if let content = String(data: data, encoding: .utf8) {
                    try content.write(toFile: destination, atomically: true, encoding: .utf8)
                }
            }
        } catch {
            print("⚠️  Не удалось скачать из: \(baseURL)")
        }
    }
}
