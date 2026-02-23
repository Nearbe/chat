import Foundation

/// Событие завершения генерации (done) в потоке LM Studio.
struct LMDoneEvent: Codable {
    /// Финальная статистика генерации
    let stats: LMStats?
}
