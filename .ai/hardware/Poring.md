# Поринг (Poring) — Local Development Machine

**Назначение:** Основная рабочая станция разработчика, где запущен AI-агент

---

## 💻 Системная конфигурация

### Основной компьютер пользователя
- **Модель:** MacBook Pro 14" 2024
- **Процессор:** Apple M4 Max (12‑ядерный CPU, 40‑ядерный GPU)
- **ОЗУ:** 128 GB Unified Memory
- **Хранилище:** SSD (конфигурация зависит от модели)

### Дополнительные устройства в парке
- Несколько Mac и Windows-ПК
- iPhone 16 Pro Max

---

## 🎯 Роль в инфраструктуре

### Local Development & Orchestration Hub
- Развертывание и управление AI-агентами
- Локальная разработка приложения Chat (Swift 6.0)
- Интеграция с LM Studio для работы с Qwen3.5-35B
- Координация между Master, Alfred и Galathea

### Основные задачи
1. **Разработка:** Swift приложение с Factory DI, Pulse logging
2. **Тестирование:** Unit/UI тесты через Xcode/IntelliJ IDEA
3. **Оркестрация:** Управление агентами через LangChain/AutoGen
4. **Интеграция:** MCP Memory Service configuration

---

## 🔗 Интеграция в систему

### Взаимодействие с удаленными устройствами
- **Master (M4 Max):** Оркестрация задач между узлами
- **Alfred (RTX 4080):** Remote inference через SSH
- **Galathea (RTX 4060 Ti):** Embeddings и preprocessing
- **Saint Celestine:** CI/CD pipeline management

### Локальная конфигурация LM Studio
```yaml
Model: Qwen3.5-35B-A3B-Q8_0
Context: 131072
Batch: 2048
RoPE Base: 10000000
Temperature: 0.7
Top P: 0.9
Top K: 40
Min P: 0.05
Penalties:
  Presence: 0.5
  Frequency: 0.3
  Repeat: 1.1
GPU Offload: MAX (41/41 layers)
Flash Attention: ON
Prompt Cache: 8192 MiB
Threads: 10
Layers CPU: 0
```

---

## 🛠 Стек разработки

| Компонент | Технология |
|-----------|------------|
| **Язык** | Swift 6.0 |
| **IDE** | IntelliJ IDEA 2025.3.3 |
| **DI Container** | Factory |
| **Logging** | Pulse |
| **Database** | SQLite.swift |
| **Build Tool** | XcodeGen (generation only) |
| **CI/CD** | Local bash scripts (Saint Celestine) |

---

## 📁 Структура проекта

```
Chat/
├── App/                    # Основное приложение
├── Features/               # Feature modules
├── Agents/                 # AI agent definitions
│   ├── analytics-engineer/
│   ├── client-developer/
│   ├── server-qa-lead/
│   └── ... (30+ agents)
├── McpMemory/              # MCP Memory Server
├── Infrastructure/lmstudio/
└── orchestrator/           # LangChain/AutoGen orchestration
```

---

## 🌐 Сетевая инфраструктура

- **Роутер:** Keenetic с 10 GbE портами
- **Протокол:** Все устройства в одной локальной сети
- **Безопасность:** Локальная сеть = no security issues
- **SSH доступ:** Настроен для Alfred, Galathea, Saint Celestine

---

## ⚙️ Технические характеристики

| Компонент | Спецификация |
|-----------|--------------|
| **CPU** | Apple M4 Max (12-core CPU) |
| **GPU** | 40-core GPU ( integrated ) |
| **RAM** | 128 GB Unified Memory |
| **Storage** | 1–4 TB SSD (config-dependent) |
| **Display** | 14" Liquid Retina XDR |
| **OS** | macOS Sonoma / Sequoia |
| **Network** | 10 GbE + Wi-Fi 6E |

---

## 🔄 Автоматизация

### CI/CD Pipeline (Saint Celestine)
```bash
# Local bash scripts for deployment
./deploy.sh          # Deployment automation
./chat-scripts.sh    # Common utilities
./download_all_docs.sh # Documentation sync
```

### Backup Strategy
- GitHub backup only (private repository)
- No cloud storage для чувствительных данных
- Локальные снапшоты через Time Machine
