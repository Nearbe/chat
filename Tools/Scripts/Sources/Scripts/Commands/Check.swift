import ArgumentParser
import Foundation

struct Check: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Техническая проверка проекта (Lint + Build + Test + Commit)")
    
    @Argument(help: "Сообщение для коммита")
    var message: String?
    
    func run() async throws {
        let device = "platform=iOS Simulator,name=iPhone 16 Pro Max"
        
        print("🚀  Начало технической проверки (Асинхронный режим)...")
        
        try await withThrowingTaskGroup(of: Void.self) { mainGroup in
            // 1. Параллельный линтинг
            mainGroup.addTask {
                print("🔍  Запуск SwiftLint...")
                try await Shell.run("swiftlint --strict")
                print("✅  SwiftLint завершен успешно.")
            }
            
            // 2. Группа генерации и последующей сборки/тестирования
            mainGroup.addTask {
                // Сначала инфраструктура (XcodeGen + SwiftGen)
                print("🏗️  Этап 1: Подготовка инфраструктуры...")
                try await withThrowingTaskGroup(of: Void.self) { genGroup in
                    genGroup.addTask { 
                        print("📦  Генерация проекта (XcodeGen)...")
                        try await Shell.run("xcodegen generate") 
                    }
                    genGroup.addTask { 
                        print("🎨  Генерация ресурсов (SwiftGen)...")
                        try await runSwiftGen() 
                    }
                    
                    try await genGroup.waitForAll()
                }
                
                // Как только генерация завершена, запускаем сборку и тесты параллельно
                print("🧪  Этап 2: Сборка и тестирование (Параллельно)...")
                try await withThrowingTaskGroup(of: Void.self) { buildGroup in
                    // Unit + UI тесты
                    buildGroup.addTask {
                        print("🧪  Запуск тестов через Test Plan (AllTests)...")
                        try? FileManager.default.removeItem(atPath: "TestResult.xcresult")
                        
                        let testCommand = [
                            "xcodebuild",
                            "-project Chat.xcodeproj",
                            "-scheme Chat",
                            "-testPlan AllTests",
                            "-destination \"\(device)\"",
                            "-resultBundlePath TestResult.xcresult",
                            "test",
                            "CODE_SIGNING_ALLOWED=NO",
                            "CODE_SIGNING_REQUIRED=NO",
                            "| grep -E \"Test Suite|passed|failed|skipped\""
                        ].joined(separator: " ")
                        
                        try await Shell.run(testCommand)
                        print("✅  Все тесты пройдены успешно.")
                    }
                    
                    // Релизная сборка
                    buildGroup.addTask {
                        print("📦  Сборка Release версии...")
                        let releaseCommand = [
                            "xcodebuild",
                            "-quiet",
                            "-project Chat.xcodeproj",
                            "-scheme Chat",
                            "-configuration Release",
                            "-destination \"generic/platform=iOS\"",
                            "SYMROOT=\"$(pwd)/build\"",
                            "build"
                        ].joined(separator: " ")
                        
                        try await Shell.run(releaseCommand)
                        print("✅  Release сборка завершена.")
                    }
                    
                    try await buildGroup.waitForAll()
                }
            }
            
            try await mainGroup.waitForAll()
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

