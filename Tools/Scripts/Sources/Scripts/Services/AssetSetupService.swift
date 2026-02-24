// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.

import Foundation

/// Сервис для настройки ассетов проекта.
enum AssetSetupService {
    /// Цветовой ассет.
    struct ColorAsset: Equatable {
        let name: String
        let red: String
        let green: String
        let blue: String
    }

    /// Стандартные цвета проекта.
    static let standardColors: [ColorAsset] = [
        ColorAsset(name: "PrimaryOrange", red: "0xFF", green: "0x9F", blue: "0x0A"),
        ColorAsset(name: "PrimaryBlue", red: "0x00", green: "0x7A", blue: "0xFF"),
        ColorAsset(name: "Success", red: "0x34", green: "0xC7", blue: "0x59"),
        ColorAsset(name: "Error", red: "0xFF", green: "0x3B", blue: "0x30"),
        ColorAsset(name: "Warning", red: "0xFF", green: "0x95", blue: "0x00"),
        ColorAsset(name: "Info", red: "0x5A", green: "0xC8", blue: "0xFA")
    ]

    /// Настраивает все ассеты.
    static func setup() async throws {
        print("🎨 Создание цветовых ассетов...")
        for color in standardColors {
            try createColorAsset(name: color.name, red: color.red, green: color.green, blue: color.blue)
        }
    }

    /// Создаёт color asset.
    private static func createColorAsset(name: String, red: String, green: String, blue: String) throws {
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
