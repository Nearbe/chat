// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import SwiftUI

extension Color {
    /// Инициализация цвета из hex строки
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }

        let length = hexSanitized.count
        switch length {
        case 6:
            self.init(
                red: Double((rgb & 0xFF0000) >> 16) / 255.0,
                green: Double((rgb & 0x00FF00) >> 8) / 255.0,
                blue: Double(rgb & 0x0000FF) / 255.0
            )
        case 8:
            self.init(
                red: Double((rgb & 0xFF000000) >> 24) / 255.0,
                green: Double((rgb & 0x00FF0000) >> 16) / 255.0,
                blue: Double((rgb & 0x0000FF00) >> 8) / 255.0,
                opacity: Double(rgb & 0x000000FF) / 255.0
            )
        default:
            return nil
        }
    }

    /// Конвертация в hex строку
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components else {
            return nil
        }

        let red = Int(components[0] * 255)
        let green = Int(components[1] * 255)
        let blue = Int(components[2] * 255)

        return String(format: "#%02X%02X%02X", red, green, blue)
    }
}

#Preview {
    VStack(spacing: 16) {
        Color(hex: "#FF9F0A")
            .frame(width: 100, height: 50)
            .cornerRadius(8)

        Color(hex: "#007AFF")
            .frame(width: 100, height: 50)
            .cornerRadius(8)

        Color(hex: "#34C759")
            .frame(width: 100, height: 50)
            .cornerRadius(8)
    }
    .padding()
}
