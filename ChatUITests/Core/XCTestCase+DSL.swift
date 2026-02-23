// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.
import XCTest

extension XCTestCase {
    /// Обертка для логирования шагов теста
    @MainActor
    func step(_ name: String, block: () -> Void) {
        XCTContext.runActivity(named: name) { _ in
            block()
        }
    }
}
