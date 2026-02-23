// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import Foundation
import SwiftUI

extension String {
    /// Проверка на nil или пустоту
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }

    /// Усечение строки до указанной длины
    func truncated(to length: Int, trailing: String = "...") -> String {
        if count <= length {
            return self
        }
        return String(prefix(length)) + trailing
    }

    /// Удаление лишних пробелов и переносов строк
    var normalized: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 8) {
        Text("nilIfEmpty: \(("".nilIfEmpty ?? "пусто"))")
        Text("truncated: \("Hello World".truncated(to: 8))")
        Text("normalized: \("  Hello   World  ".normalized)")
    }
    .padding()
}
