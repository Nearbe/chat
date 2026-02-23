// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import ArgumentParser
import Foundation

struct DownloadDocs: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Обновление локальной документации инструментов")
    
    func run() async throws {
        print("🌍  Начало обновления документации...")
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask { try await Metrics.measure(step: "Docs: LM Studio") { try await downloadLMStudio() } }
            group.addTask { try await Metrics.measure(step: "Docs: OpenAI") { try await downloadOpenAI() } }
            group.addTask { try await Metrics.measure(step: "Docs: Factory") { try await downloadFactory() } }
            group.addTask { try await Metrics.measure(step: "Docs: Pulse") { try await downloadPulse() } }
            group.addTask { try await Metrics.measure(step: "Docs: Ollama") { try await downloadOllama() } }
            group.addTask { try await Metrics.measure(step: "Docs: Codegen") { try await downloadCodegen() } }
            
            try await group.waitForAll()
        }
        
        print("✅  Вся документация успешно обновлена!")
    }
    
    private func downloadLMStudio() async throws {
        print("📦  Обновление документации LM Studio (ревизия: \(Versions.lmStudioDocs))...")
        let baseURL = "https://raw.githubusercontent.com/lmstudio-ai/docs/\(Versions.lmStudioDocs)"
        let docsDir = "Docs/LMStudio"
        let files = [
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
        
        try await downloadFiles(baseURL: baseURL, files: files, destinationDir: docsDir)
    }

    private func downloadOpenAI() async throws {
        print("📦  Обновление документации OpenAI (ревизия: \(Versions.openAIDocs))...")
        let baseURL = "https://raw.githubusercontent.com/openai/openai-openapi/\(Versions.openAIDocs)"
        let docsDir = "Docs/OpenAI"
        let files = ["openapi.yaml": "openapi.yaml"]
        try await downloadFiles(baseURL: baseURL, files: files, destinationDir: docsDir)
    }

    private func downloadFactory() async throws {
        print("📦  Обновление документации Factory (версия: \(Versions.factory))...")
        let baseURL = "https://raw.githubusercontent.com/hmlongco/Factory/\(Versions.factory)"
        let docsDir = "Docs/Factory"
        let files = ["README.md": "README.md"]
        try await downloadFiles(baseURL: baseURL, files: files, destinationDir: docsDir)
    }

    private func downloadPulse() async throws {
        print("📦  Обновление документации Pulse (версия: \(Versions.pulse))...")
        let baseURL = "https://raw.githubusercontent.com/kean/Pulse/\(Versions.pulse)"
        let docsDir = "Docs/Pulse"
        let files = ["README.md": "README.md"]
        try await downloadFiles(baseURL: baseURL, files: files, destinationDir: docsDir)
    }

    private func downloadOllama() async throws {
        print("📦  Обновление документации Ollama (ревизия: \(Versions.ollamaDocs))...")
        let baseURL = "https://raw.githubusercontent.com/ollama/ollama/\(Versions.ollamaDocs)/docs"
        let docsDir = "Docs/Ollama"
        let files = ["api.md": "api.md"]
        try await downloadFiles(baseURL: baseURL, files: files, destinationDir: docsDir)
    }

    private func downloadCodegen() async throws {
        print("📦  Обновление документации Codegen (XcodeGen: \(Versions.xcodegen), SwiftGen: \(Versions.swiftgen))...")
        let docsDir = "Docs/Codegen"
        
        // XcodeGen
        try await downloadFiles(
            baseURL: "https://raw.githubusercontent.com/yonaskolb/XcodeGen/\(Versions.xcodegen)",
            files: ["README.md": "XcodeGen/README.md"],
            destinationDir: docsDir
        )
        
        // SwiftGen
        try await downloadFiles(
            baseURL: "https://raw.githubusercontent.com/SwiftGen/SwiftGen/\(Versions.swiftgen)",
            files: ["README.md": "SwiftGen/README.md"],
            destinationDir: docsDir
        )
    }

    private func downloadFiles(baseURL: String, files: [String: String], destinationDir: String) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            for (src, dest) in files {
                group.addTask {
                    let fullURL = "\(baseURL)/\(src)"
                    let destPath = "\(destinationDir)/\(dest)"
                    let destURL = URL(fileURLWithPath: destPath)
                    
                    try FileManager.default.createDirectory(at: destURL.deletingLastPathComponent(), withIntermediateDirectories: true)
                    
                    print("📥  Downloading: \(dest)")
                    try await Shell.run("curl -s -f \"\(fullURL)\" -o \"\(destPath)\"", quiet: true)
                }
            }
            
            try await group.waitForAll()
        }
    }
}
