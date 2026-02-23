// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import SwiftUI
import SwiftData

/// - Документация: [Docs/Pulse/README.md](../../../Docs/Pulse/README.md) (инструкция по вызову консоли Pulse через жест)
/// Экран истории чатов
struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \ChatSession.updatedAt, order: .reverse) private var sessions: [ChatSession]

    let onSelectSession: (ChatSession) -> Void
    let onDeleteSession: (ChatSession) -> Void

    @State private var sessionToDelete: ChatSession?
    @State private var showingDeleteAlert = false
    @State private var searchText = ""

    private var filteredSessions: [ChatSession] {
        if searchText.isEmpty {
            return sessions
        } else {
            return sessions.filter { session in
                session.title.localizedCaseInsensitiveContains(searchText) ||
                session.modelName.localizedCaseInsensitiveContains(searchText) ||
                session.messages.contains { $0.content.localizedCaseInsensitiveContains(searchText) }
            }
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if sessions.isEmpty {
                    emptyStateView
                } else {
                    sessionsListView
                }
            }
            .navigationTitle("История")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Поиск чатов и сообщений")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
            .alert("Удалить чат?", isPresented: $showingDeleteAlert) {
                Button("Отмена", role: .cancel) {
                    sessionToDelete = nil
                }
                Button("Удалить", role: .destructive) {
                    if let session = sessionToDelete {
                        onDeleteSession(session)
                    }
                    sessionToDelete = nil
                }
            } message: {
                Text("Это действие нельзя отменить.")
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(AppTypography.iconLarge)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            Text("Нет истории")
                .font(AppTypography.headline)
                .accessibilityAddTraits(.isHeader)

            Text("Ваши чаты появятся здесь")
                .font(AppTypography.callout)
                .foregroundStyle(.secondary)
        }
    }

    private var sessionsListView: some View {
        List {
            ForEach(filteredSessions) { session in
                SessionRowView(session: session) {
                    onSelectSession(session)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        sessionToDelete = session
                        showingDeleteAlert = true
                    } label: {
                        Label("Удалить", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

#Preview {
    HistoryView(
        onSelectSession: { _ in },
        onDeleteSession: { _ in }
    )
    .modelContainer(PersistenceController.shared.container)
}
