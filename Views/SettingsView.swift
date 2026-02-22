import SwiftUI

/// Экран настроек
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var config = AppConfig.shared
    @StateObject private var themeManager = ThemeManager.shared

    @State private var showingTokenAlert = false
    @State private var newToken = ""
    @State private var authManager = DeviceAuthManager()

    var body: some View {
        NavigationStack {
            Form {
                Section("Подключение") {
                    TextField("URL LM Studio", text: $config.baseURL)
                        .textContentType(.URL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()

                    HStack {
                        Text("Таймаут")
                        Spacer()
                        Text("\(Int(config.timeout)) сек")
                            .foregroundStyle(.secondary)
                    }

                    Slider(value: $config.timeout, in: 10...120, step: 5) {
                        Text("Таймаут")
                    }
                }

                Section("Модель") {
                    HStack {
                        Text("Температура")
                        Spacer()
                        Text(String(format: "%.1f", config.temperature))
                            .foregroundStyle(.secondary)
                    }

                    Slider(value: $config.temperature, in: 0...2, step: 0.1)

                    Stepper("Макс. токенов: \(config.maxTokens)", value: $config.maxTokens, in: 512...8192, step: 512)
                }

                Section("Инструменты") {
                    Toggle("MCP Tools", isOn: $config.mcpToolsEnabled)

                    if config.mcpToolsEnabled {
                        Text("Серверные инструменты будут использоваться при генерации")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Интерфейс") {
                    Toggle("Показывать статистику", isOn: $config.showStats)
                    Toggle("Автопрокрутка", isOn: $config.autoScroll)
                }

                Section("Авторизация") {
                    HStack {
                        Text("Устройство")
                        Spacer()
                        Text(authManager.currentDeviceName)
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Статус")
                        Spacer()
                        Text(authManager.isDeviceAuthorized ? "Авторизовано" : "Не авторизовано")
                            .foregroundStyle(authManager.isDeviceAuthorized ? .green : .red)
                    }

                    if authManager.isDeviceAuthorized {
                        HStack {
                            Text("Токен")
                            Spacer()
                            Text(authManager.maskedToken ?? "Не найден")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                        }

                        Button("Изменить токен") {
                            showingTokenAlert = true
                        }
                    }
                }

                Section("О приложении") {
                    HStack {
                        Text("Версия")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("iOS")
                        Spacer()
                        Text("26.2+")
                            .foregroundStyle(.secondary)
                    }

                    Button("Сбросить настройки") {
                        config.reset()
                    }
                    .foregroundStyle(.red)
                }
            }
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
            .alert("Введите токен", isPresented: $showingTokenAlert) {
                SecureField("Токен", text: $newToken)
                Button("Отмена", role: .cancel) {
                    newToken = ""
                }
                Button("Сохранить") {
                    if !newToken.isEmpty {
                        _ = authManager.setToken(newToken)
                        newToken = ""
                    }
                }
            } message: {
                Text("Введите API токен для LM Studio")
            }
        }
    }
}

#Preview {
    SettingsView()
}
