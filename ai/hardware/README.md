# 🖥 Инфраструктура устройств Chat Project

Документация по всем устройствам в локальной инфраструктуре проекта **Chat**.

---

## 📋 Обзор инфраструктуры

```
┌─────────────────┐     ┌──────────────────────┐
│   Poring        │     │      Master          │
│ (Local Dev)     │◄───►│ (Orchestration)      │
│ M4 Max 128GB    │     │ M4 Max               │
└────────┬────────┘     └──────────┬───────────┘
         │                         │
         ▼                         ▼
┌─────────────────┐     ┌──────────────────────┐
│   Alfred        │     │    Galathea          │
│ (Inference)     │◄───►│ (Embeddings)         │
│ RTX 4080 16GB   │     │ RTX 4060 Ti 8GB      │
└─────────────────┘     └──────────────────────┘

┌─────────────────┐
│    Lilly        │
│ (Dev Workstation)│
│ i7 + Iris GPU   │
└─────────────────┘
```

---

## 🎯 Назначение устройств

| Устройство | Роль | Оборудование | Основная задача |
|------------|------|--------------|-----------------|
| **Poring** | Local Dev & Orchestration | MacBook Pro 14" M4 Max, 128GB RAM | Разработка, тестирование, управление агентами |
| **Master** | Оркестрация | M4 Max | Координация между узлами системы |
| **Alfred** | Inference Server | RTX 4080 16GB, i7-14700F, 64GB RAM | LLM inference (Qwen3.5-35B), MCP Memory Service |
| **Galathea** | Embeddings & Preprocessing | RTX 4060 Ti 8GB, i5-13400F, 32GB RAM | Векторные представления, подготовка данных |
| **Lilly** | Dev Workstation | Core i7, Iris GPU, 32GB LPDDR4X | Локальная разработка и тестирование |

---

## 📂 Структура документации

```
.ai/hardware/
├── README.md              # Эта страница (индекс)
├── Poring.md              # Основная рабочая станция разработчика
├── Master.md              # Оркестратор (M4 Max)
├── Alfred.md              # Сервер инференса (RTX 4080)
├── Galatea.md             # Embeddings server (RTX 4060 Ti)
└── Lilly.md               # Dev workstation (Core i7)
```

---

## 🔗 Связь с инфраструктурой проекта

### MCP Memory Service Deployment

```
Poring (Developer) ──SSH──► Alfred (Windows) ──HTTP──► MCP Memory Server
                                    │
                              Port 8000
                                    │
                              REST API + SSE
```

### LangChain/AutoGen Integration

```
Agent (Swift App on Poring)
    │
    ▼
LangChain Client ────────► MCP Memory Service (Alfred)
                            ├── X-Agent-ID scoped memory
                            ├── Knowledge Graph
                            └── ONNX Embeddings
```

---

## 🌐 Сетевая конфигурация

- **Роутер:** Keenetic с 10 GbE портами
- **Протокол:** Все устройства в одной локальной сети
- **Безопасность:** Локальная сеть = no security issues
- **SSH доступ:** Настроен для Alfred (Windows), Galathea, Saint Celestine

---

## 📊 Сравнительная таблица GPU

| Устройство | GPU | CUDA Cores | VRAM | Memory Bandwidth | Роль |
|------------|-----|------------|------|------------------|------|
| **Alfred** | RTX 4080 | 9,728 | 16 GB GDDR6X | 716.864 ГБ/с | Inference (LLM) |
| **Galathea** | RTX 4060 Ti | 4,352 | 8 GB GDDR6 | 288.032 ГБ/с | Embeddings |

---

## 🚀 Быстрый старт

### Проверка подключения к Alfred
```bash
ssh nearbe@<IP_ALFRED> "pwsh.exe -Command 'python --version'"
```

### Запуск MCP Memory Service на Windows
```powershell
# Установка Python через winget
winget install Python.Python.3.12

# Установка mcp-memory-service
pip install mcp-memory-service

# Запуск как фоновая служба
$env:MCP_ALLOW_ANONYMOUS_ACCESS=true
Start-Process memory -ArgumentList "server", "--http" -WindowStyle Hidden
```

---

## 📝 Обновление документации

При изменении конфигурации устройств обновите соответствующие файлы:
1. Отчет о системе NVIDIA → `./hardware/{Device}.md`
2. Системные характеристики → `./hardware/{Device}.md`
3. Сетевая конфигурация → `./hardware/README.md`

---

## 🔐 Конфиденциальность

- Все устройства находятся в локальной сети
- Данные никогда не покидают инфраструктуру (100% local)
- GitHub используется только для backup приватного репозитория
