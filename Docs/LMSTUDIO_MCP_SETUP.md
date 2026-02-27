# LM Studio MCP Bridge - Настройка Memory Service

## 🎯 Цель

Подключить локально развернутый MCP Memory Service к LM Studio через MCP Bridge.

---

## 📋 Шаг 1: Создайте конфиг файл

### Вариант A: Через редактор кода

Создайте файл `/Users/nearbe/repositories/Chat/ai/mcp/memory-service/lmstudio-mcp-config.json` со следующим содержимым:

```json
{
  "mcpServers": {
    "memory-service": {
      "command": "/Users/nearbe/repositories/Chat/ai/mcp/memory-service/.venv/bin/python",
      "args": ["-m", "mcp_memory_service.server"],
      "env": {
        "MCP_MEMORY_STORAGE_BACKEND": "sqlite_vec"
      }
    }
  }
}
```

### Вариант B: Через командную строку (терминал)

Откройте терминал и выполните:

```bash
cd /Users/nearbe/repositories/Chat/ai/mcp/memory-service

# Создайте конфиг через Python
python3 << 'EOF'
import json
config = {
    "mcpServers": {
        "memory-service": {
            "command": "/Users/nearbe/repositories/Chat/ai/mcp/memory-service/.venv/bin/python",
            "args": ["-m", "mcp_memory_service.server"],
            "env": {
                "MCP_MEMORY_STORAGE_BACKEND": "sqlite_vec"
            }
        }
    }
}
with open("lmstudio-mcp-config.json", "w") as f:
    json.dump(config, f, indent=2)
print("✅ Config created successfully!")
EOF
```

---

## 🔧 Шаг 2: Укажите путь в LM Studio

1. **Откройте LM Studio**
2. Перейдите во вкладку **MCP Server** (или AI Tools → MCP)
3. Нажмите **"Add MCP Server"** или **"Edit Config"**
4. Выберите файл конфигурации:
   ```
   /Users/nearbe/repositories/Chat/ai/mcp/memory-service/lmstudio-mcp-config.json
   ```

### Альтернативный путь для LM Studio (системный):

```bash
/Users/nearbe/Library/Application Support/lmstudio-mcp/mcp-config.json
```

---

## ✅ Шаг 3: Проверка подключения

### Проверка статуса сервера

```bash
curl http://localhost:8000/api/health
```

Ожидаемый ответ:
```json
{"status":"healthy","version":"10.18.1","timestamp":"...","uptime_seconds":123}
```

### В LM Studio

1. Откройте **MCP Server** вкладку
2. Найдите `memory-service` в списке серверов
3. Статус должен быть **"Connected"** или **"Active"**

---

## 🧪 Шаг 4: Тестирование инструментов Memory Service

После подключения, вы сможете использовать инструменты Memory Service через LM Studio:

### Пример использования:

1. **Сохранить память:**
   ```
   Сохрани архитектурное решение проекта Chat - используем Factory DI для зависимостей
   ```

2. **Поиск контекста:**
   ```
   Найди информацию об использовании инструментов MCP в проекте
   ```

3. **Веб-дашборд:**
   Откройте http://localhost:8000/ для визуального управления памятью

---

## 🔍 Структура конфига

| Поле | Значение | Описание |
|------|----------|----------|
| `mcpServers.memory-service.command` | `/Users/nearbe/repositories/Chat/ai/mcp/memory-service/.venv/bin/python` | Путь к Python интерпретатору из виртуального окружения |
| `mcpServers.memory-service.args[0]` | `-m` | Запуск модуля Python |
| `mcpServers.memory-service.args[1]` | `mcp_memory_service.server` | Модуль server.py для запуска MCP сервера |
| `mcpServers.memory-service.env.MCP_MEMORY_STORAGE_BACKEND` | `sqlite_vec` | Тип хранилища (локальное SQLite с векторами) |

---

## 🐛 Решение проблем

### Сервер не запускается

```bash
# Проверьте что venv существует и содержит Python
ls -la /Users/nearbe/repositories/Chat/ai/mcp/memory-service/.venv/bin/python

# Попробуйте запустить сервер вручную:
cd /Users/nearbe/repositories/Chat/ai/mcp/memory-source
source .venv/bin/activate
python -m mcp_memory_service.server --http
```

### LM Studio не видит конфигурацию

1. **Перезапустите LM Studio** после создания/изменения конфига
2. **Проверьте путь к файлу** — должен быть абсолютным путем
3. **Проверьте синтаксис JSON:**
   ```bash
   python3 -c "import json; json.load(open('/Users/nearbe/repositories/Chat/ai/mcp/memory-service/lmstudio-mcp-config.json'))"
   echo $?  # 0 = OK, 1 = ошибка
   ```

### Сервер уже запущен

Если Memory Service уже работает на порту 8000:

```bash
# Проверьте что порт занят
lsof -i :8000 | grep LISTEN

# Если нужно перезапустить:
kill $(lsof -t -i:8000) 2>/dev/null || true

# Затем запустите заново
cd /Users/nearbe/repositories/Chat/ai/mcp/memory-service
source .venv/bin/activate
python -m mcp_memory_service.server --http &
```

---

## 📚 Дополнительные ресурсы

- **Документация Memory Service**: https://github.com/doobidoo/mcp-memory-service/wiki
- **Web Dashboard**: http://localhost:8000/
- **API Docs**: http://localhost:8000/api/docs
