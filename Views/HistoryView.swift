import SwiftUI
import SwiftData

/// Экран истории чатов
struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \ChatSession.updatedAt, order: .reverse) private var sessions: [ChatSession]

    let onSelectSession: (ChatSession) -> Void
    let onDeleteSession: (ChatSession) -> Void

    @State private var sessionToDelete: ChatSession?
    @State private var showingDeleteAlert = false

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
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("Нет истории")
                .font(.headline)

            Text("Ваши чаты появятся здесь")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var sessionsListView: some View {
        List {
            ForEach(sessions) { session in
                Button {
                    onSelectSession(session)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(session.title)
                                .font(.headline)
                                .lineLimit(1)

                            HStack(spacing: 8) {
                                Text(session.formattedDate)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                Text("•")
                                    .foregroundStyle(.secondary)

                                Text("\(session.messageCount) сообщений")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                if session.modelName != "default" {
                                    Text("•")
                                        .foregroundStyle(.secondary)

                                    Text(session.modelName)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                            }
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
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
