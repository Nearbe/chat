import ArgumentParser
import Foundation

struct Check: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Техническая проверка проекта (Lint + Build + Test + Commit)")
    
    @Argument(help: "Сообщение для коммита")
    var message: String?
    
    func run() async throws {
        let device = "platform=iOS Simulator,name=iPhone 16 Pro Max"
        
        print("🚀  Начало технической проверки...")
        
        // Группа 1: Генерация и линтинг (Параллельно)
        print("⏳  Этап 1: Генерация и статический анализ...")
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask { try await Shell.run("xcodegen generate") }
            group.addTask { try await Shell.run("swiftlint --strict") }
            group.addTask { try await runSwiftGen() }
        }
        
        // Группа 2: Debug Build
        print("🔨  Этап 2: Сборка Debug версии...")
        try await Shell.run("xcodebuild -quiet -project Chat.xcodeproj -scheme Chat -configuration Debug -destination \"\(device)\" build CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO")
        
        // Группа 3: Тесты и Release Build (Параллельно)
        print("🧪  Этап 3: Тестирование и сборка Release версии...")
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                print("🧪  Запуск тестов...")
                try? FileManager.default.removeItem(atPath: "TestResult.xcresult")
                try await Shell.run("xcodebuild -project Chat.xcodeproj -scheme Chat -destination \"\(device)\" -enableCodeCoverage YES -resultBundlePath TestResult.xcresult test CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO | grep -E \"Test Suite|passed|failed|skipped\"")
            }
            group.addTask {
                print("📦  Сборка релизной версии...")
                try await Shell.run("xcodebuild -quiet -project Chat.xcodeproj -scheme Chat -configuration Release -destination \"generic/platform=iOS\" SYMROOT=\"$(pwd)/build\" build")
            }
        }
        
        print("✅  Техническая проверка успешно завершена!")
        
        // Группа 4: Git
        try await handleGitCommit()
    }
    
    private func runSwiftGen() async throws {
        try await Shell.run("swiftgen")
        let assetsFile = URL(fileURLWithPath: "Design/Generated/Assets.swift")
        if FileManager.default.fileExists(atPath: assetsFile.path) {
            var content = try String(contentsOf: assetsFile, encoding: .utf8)
            content = content.replacingOccurrences(
                of: "internal final class ColorAsset",
                with: "internal final class ColorAsset: @unchecked Sendable"
            )
            try content.write(to: assetsFile, atomically: true, encoding: .utf8)
        }
    }
    
    private func handleGitCommit() async throws {
        let status = try await Shell.run("git status --porcelain", quiet: true)
        if !status.isEmpty {
            let commitMessage = message ?? "Automatic commit after successful verification"
            print("📦  Добавление изменений в индекс...")
            try await Shell.run("git add .")
            print("💾  Коммит изменений: '\(commitMessage)'...")
            try await Shell.run("git commit -m \"\(commitMessage)\"")
            print("📤  Отправка в удаленный репозиторий (push)...")
            try await Shell.run("git push")
            print("🚀  Код закоммичен и отправлен!")
        } else {
            print("ℹ️  Изменений не обнаружено, коммит не требуется.")
        }
    }
}
