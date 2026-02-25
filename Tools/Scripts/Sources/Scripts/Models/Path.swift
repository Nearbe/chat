// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.

import Foundation

/// Утилита для работы с путями в файловой системе.
/// Предоставляет удобный синтаксис для конкатенации путей.
struct Path: ExpressibleByStringLiteral {
    let string: String

    init(_ path: String) {
        self.string = path
    }

    init(stringLiteral: String) {
        self.string = stringLiteral
    }

    static var currentDirectory: Path {
        Path(FileManager.default.currentDirectoryPath)
    }

    static var homeDirectory: Path {
        Path(NSHomeDirectory())
    }

    static func +(lhs: Path, rhs: String) -> Path {
        Path(lhs.string + "/" + rhs)
    }
}
