// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import ArgumentParser
import Foundation

struct Setup: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Подготовка проекта к работе (XcodeGen + SwiftGen)")

    func run() async throws {
        print("🏗️  Подготовка проекта...")

        try await Metrics.measure(step: "Setup Assets") {
            try await setupAssets()
        }
        try await Metrics.measure(step: "XcodeGen") {
            try await runXcodeGen()
        }
        try await Metrics.measure(step: "SwiftGen") {
            try await runSwiftGen()
        }

        print("✅ Проект готов к работе!")
    }

    private func runXcodeGen() async throws {
        print("🏗️  Генерация Xcode проекта (XcodeGen)...")
        try await Shell.run("xcodegen generate")
    }

    private func runSwiftGen() async throws {
        print("🎨 Генерация ресурсов (SwiftGen)...")
        try await Shell.run("swiftgen")

        // Fix for Swift 6 concurrency in generated code
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

    private func setupAssets() async throws {
        print("🎨 Создание цветовых ассетов...")
        let colors = [
            ("PrimaryOrange", "0xFF", "0x9F", "0x0A"),
            ("PrimaryBlue", "0x00", "0x7A", "0xFF"),
            ("Success", "0x34", "0xC7", "0x59"),
            ("Error", "0xFF", "0x3B", "0x30"),
            ("Warning", "0xFF", "0x95", "0x00"),
            ("Info", "0x5A", "0xC8", "0xFA")
        ]

        for (name, red, green, blue) in colors {
            try createColor(name: name, red: red, green: green, blue: blue)
        }
    }

    private func createColor(name: String, red: String, green: String, blue: String) throws {
        let dir = URL(fileURLWithPath: "Resources/Assets.xcassets/\(name).colorset")
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

        let json = """
        {
          "colors" : [
            {
              "color" : {
                "color-space" : "srgb",
                "components" : {
                  "alpha" : "1.000",
                  "blue" : "\(blue)",
                  "green" : "\(green)",
                  "red" : "\(red)"
                }
              },
              "idiom" : "universal"
            }
          ],
          "info" : {
            "author" : "xcode",
            "version" : 1
          }
        }
        """

        try json.write(to: dir.appendingPathComponent("Contents.json"), atomically: true, encoding: .utf8)
    }
}
