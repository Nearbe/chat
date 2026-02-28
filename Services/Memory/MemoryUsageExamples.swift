import Foundation

/// Примеры использования Memory Service в проекте Chat
/// Документация: Docs/memory-service-integration.md

final class MemoryUsageExamples {
    
    // MARK: - Константы для тегов
    
    enum Tags {
        static let architecture = "architecture"
        static let workflow = "workflow"
        static let infrastructure = "infrastructure"
        static let swift = "swift"
        static let ios = "ios"
        static let mcpTools = "mcp-tools"
        static let bestPractices = "best-practices"
    }
    
    enum ContextTypes {
        static let projectInfo = "project:info"
        static let architectureDecision = "architecture:decision"
        static let workflowPattern = "workflow:pattern"
        static let technicalSolution = "technical:solution"
    }
    
    // MARK: - Пример 1: Сохранить информацию о проекте
    
    func saveProjectInformation() async throws {
        
        // Используем MemoryServiceClient (нужно инициализировать через DI)
        let memory = try await createMemoryClient()
        
        // Сохраняем ключевую информацию о проекте
        try await memory.store(
            content: """
            Проект Chat - iOS/macOS приложение с использованием Swift 6.0, Factory DI для инъекции зависимостей, Pulse logging для логирования, SQLite.swift для базы данных. MCP Server интегрирован через LM Studio Bridge.
            
            Основные компоненты:
            - Core/, Data/, Services/ - ядро приложения
            - Features/, Windows/ - функциональные блоки
            - Tools/ - инструменты для AI ассистента
            - Docs/ - документация
            """,
            tags: [Tags.architecture, Tags.swift, Tags.ios],
            metadata: [
                "type": ContextTypes.projectInfo,
                "project": "Chat",
                "stack": ["Swift 6.0", "Factory DI", "Pulse logging", "SQLite.swift"]
            ]
        )
    }
    
    // MARK: - Пример 2: Сохранить архитектурное решение
    
    func saveArchitectureDecision() async throws {
        
        let memory = try await createMemoryClient()
        
        try await memory.store(
            content: """
            Архитектурное решение: Использование Factory Pattern для Dependency Injection
            
            Преимущества:
            1. Централизованное управление зависимостями
            2. Легкое тестирование через мокирование
            3. Явные зависимости в коде
            4. Поддержка переиспользования компонентов
            
            Реализация:
            - Factory протокол для создания зависимостей
            - DI Container в App/ или Core/
            - Инъекция через конструкторы сервисов
            """,
            tags: [Tags.architecture, Tags.bestPractices],
            metadata: [
                "type": ContextTypes.architectureDecision,
                "decision_date": Date().iso8601(),
                "author": "AI Assistant"
            ]
        )
    }
    
    // MARK: - Пример 3: Сохранить workflow разработки
    
    func saveWorkflowPattern() async throws {
        
        let memory = try await createMemoryClient()
        
        try await memory.store(
            content: """
            Workflow разработки с использованием MCP Tools:
            
            Цикл работы:
            1. Планирование (sequential-thinking) - декомпозиция задачи
            2. Контекст проекта - запросить структуру, файлы, git status
            3. Выбор инструмента - минимальная сложность для решения
            4. Выполнение и проверка - результат соответствует ожиданиям?
            5. Commit после каждого изменения - дисциплина версионирования
            
            Инструменты:
            - MCP IDEA - для контекста проекта
            - MCP AI-FS - для файловых операций
            - Context7 - для документации библиотек
            - Memory Service - для сохранения знаний
            """,
            tags: [Tags.workflow, Tags.mcpTools],
            metadata: [
                "type": ContextTypes.workflowPattern,
                "tools_used": ["MCP IDEA", "AI-FS", "Context7", "Memory Service"]
            ]
        )
    }
    
    // MARK: - Пример 4: Сохранить технические решения
    
    func saveTechnicalSolution() async throws {
        
        let memory = try await createMemoryClient()
        
        try await memory.store(
            content: """
            Технические решения для AI ассистента:
            
            LLM: Qwen3.5-35B-A3B-Q8_0 через LM Studio MCP Bridge
            
            Инфраструктура:
            - Master M4 Max (основной)
            - Alfred RTX 4080, Galathea RTX 4060 Ti, Saint Celestine iPhone 16 Pro Max
            - GitHub backup только (без облачного хранилища)
            
            Интеграция:
            - MCP IDEA для анализа кода и структуры проекта
            - Context7 для документации библиотек вместо fetch_*
            - Memory Service для сохранения контекста между сессиями
            
            Принципы работы:
            1. Контекст вокруг уже существует (не хранить, а запрашивать)
            2. Инструменты — средство, не цель
            3. Дисциплина коммитов после каждого изменения
            """,
            tags: [Tags.infrastructure, Tags.bestPractices],
            metadata: [
                "type": ContextTypes.technicalSolution,
                "llm": "Qwen3.5-35B-A3B-Q8_0",
                "hardware": ["M4 Max", "RTX 4080", "iPhone 16 Pro Max"]
            ]
        )
    }
    
    // MARK: - Пример 5: Семантический поиск
    
    func searchForWorkflowInformation() async throws {
        
        let memory = try await createMemoryClient()
        
        // Поиск информации о workflow разработки
        let results = try await memory.search(
            query: "как использовать MCP IDEA для получения контекста проекта",
            tags: [Tags.mcpTools, Tags.workflow],
            limit: 5
        )
        
        print("Найдено \(results.count) записей:")
        for item in results {
            print("- \(item.content.prefix(100))...")
        }
    }
    
    // MARK: - Пример 6: Автоматическое сохранение при событиях
    
    func autoSaveOnCommit() async throws {
        
        let memory = try await createMemoryClient()
        
        // Сохранить информацию о коммите
        try await memory.store(
            content: "Выполнены изменения в Tools/MemoryService/ - создан MemoryServiceClient и протокол",
            tags: [Tags.workflow, Tags.mcpTools],
            metadata: [
                "type": ContextTypes.technicalSolution,
                "event": "commit",
                "files_changed": ["Services/Memory/MemoryServiceClient.swift"]
            ]
        )
    }
    
    // MARK: - Helper Methods
    
    private func createMemoryClient() async throws -> MemoryServiceProtocol {
        // Здесь нужно получить клиент из DI контейнера
        // Пример: let memory = container.resolve(MemoryServiceProtocol.self)
        
        return MemoryServiceClient()
    }
}

// MARK: - Extension для Date

extension Date {
    var iso8601: String {
        ISO8601DateFormatter().string(from: self)
    }
}
