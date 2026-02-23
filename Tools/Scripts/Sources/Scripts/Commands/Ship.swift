// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import ArgumentParser
import Foundation

/// Команда для выполнения финальной проверки и подготовки проекта к отправке.
struct Ship: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Доставка продукта (Release Build + Deploy)")

    /// Основная логика подготовки к шиппингу.
    func run() async throws {
        print("🚢  Начало доставки продукта...")

        let deviceName = "Saint Celestine"
        let appPath = "build/Release-iphoneos/Chat.app"
        let bundleID = "ru.nearbe.chat"

        // 1. Сборка Release
        try await Metrics.measure(step: "Build Release") {
            print("📦  Сборка Release конфигурации...")
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
            try await Shell.run(releaseCommand, quiet: true, streamingPrefix: "[Build]", logName: "Build Release")
        }

        guard FileManager.default.fileExists(atPath: appPath) else {
            print("❌  Ошибка: Релизная сборка не найдена по пути \(appPath)")
            throw ExitCode(1)
        }

        // 2. Доставка на устройство
        try await Metrics.measure(step: "Ship App") {
            print("📱  Установка на устройство (\(deviceName))...")
            try await Shell.run("xcrun devicectl device install app --device \"\(deviceName)\" \"\(appPath)\"")

            print("🚀  Запуск приложения...")
            try await Shell.run("xcrun devicectl device process launch --device \"\(deviceName)\" \(bundleID)")
        }

        print("📦  Продукт успешно доставлен на устройство '\(deviceName)'!")
    }
}
