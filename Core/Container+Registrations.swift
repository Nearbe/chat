// MARK: - Связь с документацией: Factory (Версия: 2.3.0). Статус: Синхронизировано.
import Factory
import Foundation
import SwiftUI

/// - Документация: [Docs/Factory/README.md](../Docs/Factory/README.md)
@MainActor
extension Container {
    /// Менеджер сессий SwiftData
    var sessionManager: Factory<ChatSessionManager> {
        self { @MainActor in ChatSessionManager(modelContext: PersistenceController.shared.mainContext) }.singleton
    }

    /// Основной сетевой сервис
    var networkService: Factory<NetworkService> {
        self { @MainActor in NetworkService(deviceName: DeviceIdentity.currentName) }.singleton
    }

    /// Сервис логики чата
    var chatService: Factory<ChatService> {
        self { @MainActor in ChatService(networkService: self.networkService()) }.singleton
    }

    /// Монитор сетевого статуса
    var networkMonitor: Factory<NetworkMonitor> {
        self { @MainActor in NetworkMonitor() }.singleton
    }

    /// Сервис мониторинга и управления LM Studio сервером
    var serverStatusService: Factory<ServerStatusService> {
        self {
            @MainActor in ServerStatusService()
        }.singleton
    }
}
