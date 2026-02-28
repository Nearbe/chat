# Lumina MCP Integration Guide

## 🎯 Что такое Lumina?

Lumina — это мощный MCP (Model Context Protocol) сервер для LM Studio с расширенными возможностями работы с документацией и контекстом.

## 📦 Установка

### Быстрый старт:

1. **Проверьте конфигурацию:**
   ```bash
   cat ai/mcp/lumina/lmstudio-mcp-config.json
   ```

2. **Запустите сервер:**
   ```bash
   cd ai/mcp/lumina
   ./run_server.sh
   ```

3. **Настройте LM Studio:**
   - Откройте LM Studio Settings
   - Добавьте MCP сервер с конфигурацией из `ai/mcp/lumina/`

### Подробная документация:

- [📖 Полный README](../mcp/lumina/README.md)
- [⚙️ Настройка LM Studio](../mcp/lumina/LMSTUDIO_MCP_CONFIG.md)
- [🔗 Подключение к LM Studio](../mcp/lumina/HOW_TO_CONNECT_LMSTUDIO.md)

## 🚀 Основные возможности

### Документация проекта:
- Поиск и навигация по документации Chat
- Семантический поиск в MD файлах
- Интеграция с Memory Service

### Работа с кодом:
- Анализ структуры проекта
- Поиск паттернов в коде
- Генерация примеров использования

### MCP инструменты:
- Filesystem operations
- Memory management
- Code analysis

## 🔧 Конфигурация

Пример конфигурации для LM Studio:

```json
{
  "mcpServers": {
    "lumina": {
      "command": "python",
      "args": ["src/main.py"],
      "cwd": "/Users/nearbe/repositories/Chat/ai/mcp/lumina"
    }
  }
}
```

## 📚 Использование в проекте

Lumina интегрирован в нашу workflow:

1. **Документация** — быстрый поиск по MD файлам проекта
2. **Memory Service** — хранение контекста сессий
3. **AI Filesystem MCP** — работа с файлами через LLM

## 🆘 Troubleshooting

### Проблемы с подключением:
1. Проверьте что сервер запущен: `ps aux | grep lumina`
2. Убедитесь что порт свободен
3. Перезапустите LM Studio

### Ошибки конфигурации:
- Проверьте пути в `lmstudio-mcp-config.json`
- Убедитесь что Python dependencies установлены

## 📞 Контакты

По вопросам и баг-репортам обращайтесь к team-lead или создайте issue.

---

**Версия:** 1.0  
**Дата:** 2025-01-XX
