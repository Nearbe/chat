import SwiftUI
import SwiftData
import UIKit

// MARK: - Shield Shape (3D объект)
struct ShieldShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let w = rect.width
        let h = rect.height

        // Начинаем сверху по центру
        path.move(to: CGPoint(x: w * 0.5, y: 0))

        // Верхняя правая часть - прямая линия
        path.addLine(to: CGPoint(x: w, y: h * 0.25))

        // Правая сторона - плавная дуга наружу
        path.addQuadCurve(
            to: CGPoint(x: w * 0.5, y: h),
            control: CGPoint(x: w * 1.1, y: h * 0.65)
        )

        // Левая сторона - плавная дуга наружу
        path.addQuadCurve(
            to: CGPoint(x: 0, y: h * 0.25),
            control: CGPoint(x: w * -0.1, y: h * 0.65)
        )

        // Завершаем верхнюю часть
        path.addLine(to: CGPoint(x: w * 0.5, y: 0))

        path.closeSubpath()

        return path
    }
}

/// Главный экран чата
struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @Environment(\.modelContext) private var modelContext
    @State private var showingHistory = false
    @State private var showingModelPicker = false
    @State private var scrollProxy: ScrollViewProxy?
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var shieldScale: CGFloat = 1.0
    @State private var shieldRotationX: Double = 0
    @State private var shieldRotationY: Double = 0
    @State private var isPulsing = true
    @State private var fingerPosition: CGPoint = .zero
    @State private var isPressed = false
    @State private var fingerOnShield = false
    @State private var pulseKey: Int = 0
    @State private var idleRotation: Double = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if !viewModel.isAuthenticated {
                    tokenRequiredView
                } else if viewModel.messages.isEmpty {
                    emptyStateView
                } else {
                    chatMessagesView
                }

                inputAreaView
            }
            .contentShape(Rectangle())
            .onTapGesture {
                UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .flatMap { $0.windows }
                    .first(where: { $0.isKeyWindow })?
                    .endEditing(true)
            }
            .onAppear {
                viewModel.refreshAuthentication()
                Task {
                    await viewModel.checkServerConnection()
                }
            }
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingHistory = true
                    } label: {
                        Image(systemName: "list.bullet")
                    }
                    .accessibilityLabel("История чатов")
                }

                ToolbarItem(placement: .principal) {
                    Button {
                        showingModelPicker = true
                    } label: {
                        HStack(spacing: 4) {
                            Text(viewModel.config.selectedModel.isEmpty ? "Выбрать модель" : viewModel.config.selectedModel)
                                .lineLimit(1)
                            Image(systemName: "chevron.down")
                                .font(.caption)
                        }
                    }
                    .accessibilityLabel("Выбор модели")
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Circle()
                        .fill(viewModel.isServerReachable ? Color.green : Color.red)
                        .frame(width: 10, height: 10)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.config.mcpToolsEnabled.toggle()
                    } label: {
                        Image(systemName: viewModel.config.mcpToolsEnabled ? "wrench.and.screwdriver.fill" : "wrench.and.screwdriver")
                            .foregroundStyle(viewModel.config.mcpToolsEnabled ? ThemeManager.shared.accentColor : .secondary)
                    }
                }

            }
            .sheet(isPresented: $showingHistory) {
                HistoryView(
                    onSelectSession: { session in
                        viewModel.loadSession(session)
                        showingHistory = false
                    },
                    onDeleteSession: { session in
                        viewModel.deleteSession(session)
                    }
                )
            }
            .sheet(isPresented: $showingModelPicker) {
                ModelPicker(
                    models: viewModel.availableModels,
                    selectedModel: $viewModel.config.selectedModel
                )
            }
            .onChange(of: viewModel.errorMessage) {
                // Ошибки обрабатываются без показа алерта
                // viewModel.errorMessage очищается автоматически
            }
            .task {
                viewModel.setModelContext(modelContext)
                await viewModel.loadModels()
            }
            .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
                viewModel.refreshAuthentication()
            }
            .onChange(of: viewModel.messages.count) {
                if viewModel.config.autoScroll {
                    scrollToBottom()
                }
            }
        }
    }

    // MARK: - Auth Required View

    private var tokenRequiredView: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let size = screenWidth
            let halfSize = size / 2
            let halfShieldW: CGFloat = 125
            let halfShieldH: CGFloat = 150

            VStack(spacing: 20) {
                ZStack {
                    // Невидимый слой для жестов
                    Color.clear
                        .contentShape(Rectangle())
                        .frame(width: size, height: size)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let location = value.location
                                    let isInsideZone = location.x >= 0 && location.x <= size &&
                                                       location.y >= 0 && location.y <= size
                                    let isInsideShield = location.x >= halfSize - halfShieldW &&
                                                          location.x <= halfSize + halfShieldW &&
                                                          location.y >= halfSize - halfShieldH &&
                                                          location.y <= halfSize + halfShieldH

                                    if isInsideShield {
                                        if !isPressed {
                                            isPressed = true
                                            fingerOnShield = true
                                        }

                                        // Останавливаем пульсацию (только флаг, без scale)
                                        if isPulsing {
                                            isPulsing = false
                                        }

                                        // Наклон щита
                                        let normalizedX = (location.x - halfSize) / halfShieldW
                                        let normalizedY = (location.y - halfSize) / halfShieldH
                                        let rotationX = -normalizedY * 25
                                        let rotationY = normalizedX * 25
                                        withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                                            shieldRotationX = rotationX
                                            shieldRotationY = rotationY
                                        }
                                    } else if isInsideZone && !isInsideShield {
                                        // Палец в зоне но вне щита
                                        fingerOnShield = false
                                        isPulsing = false
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0.2)) {
                                            shieldRotationX = 0
                                            shieldRotationY = 0
                                        }
                                    } else if !isInsideZone {
                                        // Палец вышел за пределы зоны
                                        fingerOnShield = false
                                        isPressed = false
                                        isPulsing = true
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0.2)) {
                                            shieldRotationX = 0
                                            shieldRotationY = 0
                                        }
                                        pulseKey += 1
                                    }
                                }
                                .onEnded { _ in
                                    let wasOnShield = fingerOnShield
                                    isPressed = false
                                    isPulsing = true
                                    fingerOnShield = false

                                    // Возобновляем пульсацию
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0.3)) {
                                        shieldRotationX = 0
                                        shieldRotationY = 0
                                    }

                                    // Триггер пульсации
                                    pulseKey += 1

                                    // Проверяем был ли тап на щите
                                    if wasOnShield {
                                        if let pasteboardString = UIPasteboard.general.string,
                                           !pasteboardString.isEmpty,
                                           pasteboardString.hasPrefix("sk-lm") {
                                            viewModel.saveToken(pasteboardString)
                                        } else {
                                            errorMessage = "Неверный токен. Должен начинаться с «sk-lm»"
                                            showError = true
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                                showError = false
                                            }
                                        }
                                    }
                                }
                        )

                    // Щит - упрощённый с правильным 3D эффектом
                    ZStack {
                        // Основной щит
                        Image(systemName: "shield.fill")
                            .font(.system(size: 280))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        ThemeManager.shared.accentColor,
                                        ThemeManager.shared.accentColor.opacity(0.7),
                                        ThemeManager.shared.accentColor.opacity(0.5)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: .black.opacity(0.5), radius: 30, x: 0, y: 15)
                            .scaleEffect(shieldScale)
                            .rotation3DEffect(.degrees(shieldRotationX), axis: (x: 1, y: 0, z: 0), perspective: 0.6)
                            .rotation3DEffect(.degrees(shieldRotationY + idleRotation), axis: (x: 0, y: 1, z: 0), perspective: 0.6)

                        // Замок
                        Image(systemName: "lock.fill")
                            .font(.system(size: 75, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, .white.opacity(0.6)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
                            .scaleEffect(shieldScale)
                            .rotation3DEffect(.degrees(shieldRotationX), axis: (x: 1, y: 0, z: 0), perspective: 0.6)
                            .rotation3DEffect(.degrees(shieldRotationY + idleRotation), axis: (x: 0, y: 1, z: 0), perspective: 0.6)
                            .allowsHitTesting(false)
                    }
                    .allowsHitTesting(false)
                    .id(pulseKey)
                    .onChange(of: pulseKey) { _, _ in
                        shieldScale = 1.0
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.spring(response: 0.8, dampingFraction: 0.4).repeatForever(autoreverses: true)) {
                                shieldScale = 1.1
                            }
                        }
                    }
                    .onAppear {
                        // Idle анимация для постоянного 3D эффекта
                        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                            idleRotation = 8
                        }
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.4).repeatForever(autoreverses: true)) {
                            shieldScale = 1.1
                        }
                    }
                }
                .frame(width: size, height: size)

                Text("Требуется токен")
                    .font(.headline)

                Text("Скопируйте токен и нажмите на щит")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .overlay(alignment: .bottom) {
            if showError {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text(errorMessage)
                        .font(.subheadline)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(Color.red.opacity(0.9))
                .clipShape(Capsule())
                .shadow(radius: 10, y: 5)
                .padding(.bottom, 40)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showError)
    }

    // MARK: - Empty State View

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("Начните разговор")
                .font(.headline)

            Text("Отправьте сообщение, чтобы получить ответ от AI")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Chat Messages View

    private var chatMessagesView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.messages, id: \.id) { message in
                        MessageBubble(
                            message: message,
                            onDelete: { viewModel.deleteMessage(message) },
                            onEdit: { newContent in
                                Task {
                                    await viewModel.editMessage(message, newContent: newContent)
                                }
                            }
                        )
                        .id(message.id)
                    }

                    if !viewModel.toolCalls.isEmpty {
                        ForEach(viewModel.toolCalls) { call in
                            ToolCallView(toolCall: call)
                        }
                    }

                    if viewModel.config.showStats && !viewModel.isGenerating {
                        GenerationStatsView(stats: viewModel.currentStats)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .onAppear {
                scrollProxy = proxy
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }

    // MARK: - Input Area View

    private var inputAreaView: some View {
        VStack(spacing: 0) {
            // Иконки статуса над всей областью ввода (только для авторизованных)
            if viewModel.isAuthenticated {
                HStack(alignment: .bottom) {
                    Spacer()
                    StatusBadgeView(
                        isConnected: viewModel.isConnected,
                        isServerReachable: viewModel.isServerReachable,
                        isModelSelected: !viewModel.config.selectedModel.isEmpty
                    )
                    .padding(.bottom, 16)
                }
                .frame(height: 52)
                .padding(.trailing, 16)
                .background(Color(uiColor: .systemBackground))
            }

            if viewModel.isAuthenticated {
                HStack(alignment: .bottom, spacing: 8) {
                    TextField("Сообщение...", text: $viewModel.inputText, axis: .vertical)
                        .textFieldStyle(.plain)
                        .lineLimit(1...10)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.clear)
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color(uiColor: .systemGray4), lineWidth: 1)
                        )
                        .accessibilityLabel("Ввод сообщения")
                        .accessibilityHint("Введите текст сообщения")

                    if viewModel.isAuthenticated {
                        Button {
                            if viewModel.isGenerating {
                                viewModel.stopGeneration()
                            } else {
                                Task {
                                    await viewModel.sendMessage()
                                }
                            }
                        } label: {
                            Image(systemName: viewModel.isGenerating ? "stop.fill" : "arrow.up.circle.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(viewModel.isGenerating ? .red : ThemeManager.shared.accentColor)
                        }
                        .disabled(!viewModel.isGenerating && (viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !viewModel.isServerReachable || viewModel.config.selectedModel.isEmpty))
                        .opacity((viewModel.isGenerating || (!viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && viewModel.isServerReachable && !viewModel.config.selectedModel.isEmpty)) ? 1.0 : 0.5)
                        .accessibilityLabel(viewModel.isGenerating ? "Остановить генерацию" : "Отправить сообщение")
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
        }
    }

    // MARK: - Helpers

    private func scrollToBottom() {
        guard let lastMessage = viewModel.messages.last else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                scrollProxy?.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
    
}

#Preview {
    ChatView()
        .modelContainer(PersistenceController.shared.container)
}
