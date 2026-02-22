import Foundation

/// Ответ скачивания модели
struct LMDownloadResponse: Codable {
    let jobId: String?
    let status: String
    let completedAt: String?
    let totalSizeBytes: Int64?
    let startedAt: String?

    enum CodingKeys: String, CodingKey {
        case jobId = "job_id"
        case status
        case completedAt = "completed_at"
        case totalSizeBytes = "total_size_bytes"
        case startedAt = "started_at"
    }
}
