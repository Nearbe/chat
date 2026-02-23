// MARK: - Связь с документацией: SnapshotTesting (Версия: 1.15.4). Статус: Синхронизировано.
import Foundation
import SwiftData
@testable import Chat

/// Помощник для создания in-memory контейнера SwiftData для тестов
enum TestHelpers {
    @MainActor
    static func createInMemoryContainer() -> ModelContainer {
        let schema = Schema([
            ChatSession.self,
            Message.self
        ])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create in-memory ModelContainer: \(error.localizedDescription)")
        }
    }
}

// MARK: - Фабрики тестовых данных

extension ModelInfo {
    /// Создает экземпляр ModelInfo для тестов
    static func make(
        id: String = "test-model",
        displayName: String = "Test Model"
    ) -> ModelInfo {
        ModelInfo(id: id, displayName: displayName)
    }
}

extension Message {
    /// Создает экземпляр Message для тестов
    static func make(
        id: UUID = UUID(),
        role: String = "user",
        content: String = "Test content",
        sessionId: UUID = UUID(),
        index: Int = 0,
        createdAt: Date = Date()
    ) -> Message {
        Message(
            id: id,
            content: content,
            role: role,
            createdAt: createdAt,
            index: index,
            sessionId: sessionId
        )
    }
}

extension ChatSession {
    /// Создает экземпляр ChatSession для тестов
    static func make(
        id: UUID = UUID(),
        title: String = "Test Session",
        modelName: String = "test-model",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) -> ChatSession {
        ChatSession(
            id: id,
            title: title,
            createdAt: createdAt,
            updatedAt: updatedAt,
            modelName: modelName
        )
    }
}

import SnapshotTesting
import UIKit

extension ViewImageConfig {
    /// Конфигурация для iPhone 16 Pro Max для SnapshotTesting
    public static let iPhone16ProMax = ViewImageConfig.iphone16ProMax

    public static let iphone16ProMax = ViewImageConfig(
        safeArea: UIEdgeInsets(top: 59, left: 0, bottom: 34, right: 0),
        size: CGSize(width: 440, height: 956),
        traits: .iphone16ProMax
    )
}

extension UITraitCollection {
    public static let iphone16ProMax = UITraitCollection(mutations: { traits in
        traits.forceTouchCapability = .unavailable
        traits.layoutDirection = .leftToRight
        traits.preferredContentSizeCategory = .medium
        traits.userInterfaceIdiom = .phone
        traits.horizontalSizeClass = .compact
        traits.verticalSizeClass = .regular
        traits.displayScale = 3
        traits.displayGamut = .P3
        traits.userInterfaceStyle = .light
    })
}
