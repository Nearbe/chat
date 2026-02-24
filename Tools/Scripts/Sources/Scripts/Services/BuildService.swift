// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.

import Foundation

/// Сервис для сборки и доставки приложения.
enum BuildService {
    /// Путь к Release сборке.
    static let releasePath = "build/Release-iphoneos/Chat.app"

    /// Bundle ID приложения.
    static let bundleID = "ru.nearbe.chat"

    /// Выполняет Release сборку.
    static func buildRelease() async throws {
        print("📦  Сборка Release конфигурации...")

        let command = [
            "xcodebuild",
            "-quiet",
            "-project Chat.xcodeproj",
            "-scheme Chat",
            "-configuration Release",
            "-destination \"generic/platform=iOS\"",
            "SYMROOT=\"$(pwd)/build\"",
            "build"
        ].joined(separator: " ")

        try await Shell.run(command, quiet: true, streamingPrefix: "[Build]", logName: "Build Release")

        guard FileManager.default.fileExists(atPath: releasePath) else {
            throw BuildError.releaseBuildNotFound
        }
    }

    /// Устанавливает приложение на устройство.
    static func installToDevice(deviceName: String) async throws {
        print("📱  Установка на устройство (\(deviceName))...")
        try await Shell.run(
            "xcrun devicectl device install app --device \"\(deviceName)\" \"\(releasePath)\""
        )
    }

    /// Запускает приложение на устройстве.
    static func launchApp(deviceName: String) async throws {
        print("🚀  Запуск приложения...")
        try await Shell.run(
            "xcrun devicectl device process launch --device \"\(deviceName)\" \(bundleID)"
        )
    }

    /// Выполняет полную доставку на устройство.
    static func ship(deviceName: String) async throws {
        try await buildRelease()
        try await installToDevice(deviceName: deviceName)
        try await launchApp(deviceName: deviceName)
    }
}

/// Ошибки сборки.
enum BuildError: Error, LocalizedError {
    case releaseBuildNotFound

    var errorDescription: String? {
        switch self {
        case .releaseBuildNotFound:
            return "Релизная сборка не найдена по пути \(BuildService.releasePath)"
        }
    }
}
