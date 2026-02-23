// MARK: - Связь с документацией: LM Studio (Версия: main). Статус: Синхронизировано.
import Foundation

/// Текущий статус задачи скачивания модели в LM Studio.
struct LMDownloadStatus: Codable {
    /// Уникальный идентификатор задачи скачивания
    let jobId: String

    /// Текущее состояние (например, "downloading", "completed", "failed")
    let status: String

    /// Прогресс скачивания (от 0.0 до 1.0)
    let progress: Double?

    /// Общий размер скачиваемого файла в байтах
    let totalSizeBytes: Int64?

    /// Количество уже скачанных байт
    let downloadedSizeBytes: Int64?

    /// Время начала задачи
    let startedAt: String?

    /// Время завершения задачи
    let completedAt: String?

    /// Сообщение об ошибке (если статус "failed")
    let error: String?

    enum CodingKeys: String, CodingKey {
        case jobId = "job_id"
        case status
        case progress
        case totalSizeBytes = "total_size_bytes"
        case downloadedSizeBytes = "downloaded_size_bytes"
        case startedAt = "started_at"
        case completedAt = "completed_at"
        case error
    }
}
