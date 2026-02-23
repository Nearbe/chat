import Foundation

/// Ответ от LM Studio API, подтверждающий запуск задачи на скачивание модели.
struct LMDownloadResponse: Codable {
    /// Идентификатор созданной задачи скачивания (job ID)
    let jobId: String?
    
    /// Текущий статус (например, "downloading", "queued" или "completed")
    let status: String
    
    /// Время завершения скачивания (если уже завершено)
    let completedAt: String?
    
    /// Общий размер модели в байтах
    let totalSizeBytes: Int64?
    
    /// Время начала скачивания
    let startedAt: String?

    enum CodingKeys: String, CodingKey {
        case jobId = "job_id"
        case status
        case completedAt = "completed_at"
        case totalSizeBytes = "total_size_bytes"
        case startedAt = "started_at"
    }
}
