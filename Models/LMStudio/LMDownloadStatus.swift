import Foundation

/// Статус скачивания
struct LMDownloadStatus: Codable {
    let jobId: String
    let status: String
    let progress: Double?
    let totalSizeBytes: Int64?
    let downloadedSizeBytes: Int64?
    let startedAt: String?
    let completedAt: String?
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
