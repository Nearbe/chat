import ArgumentParser
import Foundation

struct Ship: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Доставка продукта (Release Build + Deploy)")
    
    func run() async throws {
        // Проверка на запуск от root
        if NSUserName() != "root" {
            print("⚖️  Запуск с правами администратора...")
            let args = ProcessInfo.processInfo.arguments
            let command = "sudo " + args.joined(separator: " ")
            try await Shell.run(command)
            return
        }
        
        print("🚢  Начало доставки продукта...")
        
        let deviceName = "Saint Celestine"
        let appPath = "build/Release-iphoneos/Chat.app"
        let bundleID = "ru.nearbe.chat"
        
        guard FileManager.default.fileExists(atPath: appPath) else {
            print("❌  Ошибка: Релизная сборка не найдена.")
            print("💡  Запустите техническую проверку для сборки: swift run scripts check")
            throw ExitCode(1)
        }
        
        print("📱  Установка на устройство (\(deviceName))...")
        try await Shell.run("xcrun devicectl device install app --device \"\(deviceName)\" \"\(appPath)\"")
        
        print("🚀  Запуск приложения...")
        try await Shell.run("xcrun devicectl device process launch --device \"\(deviceName)\" \(bundleID)")
        
        print("📦  Продукт успешно доставлен на устройство '\(deviceName)'!")
    }
}
