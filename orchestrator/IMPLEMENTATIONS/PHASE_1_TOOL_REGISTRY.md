# 🔧 Фаза 1: Tool Registry - Реализация

**Цель**: Централизованный реестр инструментов для агентов с автоматической генерацией function definitions для LM Studio

---

## 📋 Задачи Фазы 1

### ✅ Что нужно сделать:

| № | Задача | Статус |
|---|--------|--------|
| 1.1 | Создать структуру проекта `orchestrator/tools/` | ⬜ |
| 1.2 | Реализовать `ToolRegistry` класс | ⬜ |
| 1.3 | Создать декоратор `@tool()` для регистрации функций | ⬜ |
| 1.4 | Добавить safety checks и rate limiting | ⬜ |
| 1.5 | Создать готовые инструменты (file_system, network, search) | ⬜ |
| 1.6 | Интегрировать с LM Studio API | ⬜ |
| 1.7 | Написать unit tests | ⬜ |

---

## 🏗️ Архитектура Tool Registry

### Компоненты:

```
tools/
├── __init__.py              # Экспорт публичного API
├── registry.py             # Центральный реестр инструментов
├── decorators.py           # Декоратор @tool() и @registry.register()
├── safety.py               # Safety checks и rate limiting
├── types.py                # Типы данных (Pydantic models)
└── tools/                  # Готовые инструменты
    ├── __init__.py
    ├── base.py             # Базовый класс для инструментов
    ├── file_system.py      # Работа с файловой системой
    ├── network.py          # HTTP запросы и API
    └── search.py           # Поиск в проекте
```

### Ключевые классы:

#### 1. `ToolRegistry` (registry.py)
- Хранит все зарегистрированные инструменты
- Генерирует function definitions для LM Studio
- Поддерживает safety checks и rate limiting

#### 2. `@tool()` декоратор (decorators.py)
```python
@tool(
    name="get_file_content",
    description="Читает содержимое файла по пути",
    parameters={...}
)
def get_file_content(path: str) -> str:
    ...
```

#### 3. Safety Manager (safety.py)
- Rate limiting для каждого инструмента
- Whitelist/blacklist paths и URLs
- Проверка безопасности вызовов

---

## 📝 Спецификация классов

### ToolRegistry

**Методы:**
- `register(name: str, func: Callable) -> None` - зарегистрировать инструмент
- `get_function_definition(name: str) -> dict` - получить definition для LM Studio
- `get_all_functions() -> List[dict]` - все function definitions
- `call(name: str, **kwargs) -> Any` - вызвать инструмент с safety checks
- `add_rate_limiter(name: str, max_calls: int, window_seconds: int)`

### Tool Definition (Pydantic model)

```python
class ToolDefinition(BaseModel):
    name: str
    description: str
    parameters: dict  # JSON schema
    required: List[str]
    safety_checks: List[SafetyCheck] = []
    rate_limit: Optional[RateLimitConfig] = None
```

---

## 🔐 Safety Checks

### Типы проверок:
1. **Path validation** - whitelist/blacklist путей для файловой системы
2. **URL validation** - только доверенные домены для HTTP запросов
3. **Rate limiting** - ограничение количества вызовов
4. **Timeout** - максимальное время выполнения

### Пример configuration:
```python
SAFETY_CONFIG = {
    "file_system": {
        "allowed_paths": ["/Users/nearbe/repositories/Chat"],
        "blocked_extensions": [".env", ".pem", ".key"]
    },
    "network": {
        "allowed_domains": ["api.github.com", "lmstudio.ai"],
        "max_request_size": 1024 * 1024  # 1MB
    }
}
```

---

## 🚀 Пример использования

### Регистрация инструмента:
```python
from tools import ToolRegistry, tool

registry = ToolRegistry()

@tool(
    name="list_directory",
    description="Список файлов в директории",
    parameters={
        "type": "object",
        "properties": {
            "path": {"type": "string"}
        },
        "required": ["path"]
    }
)
def list_directory(path: str) -> List[str]:
    """Список файлов в директории"""
    return os.listdir(path)

# Получить function definition для LM Studio
function_def = registry.get_function_definition("list_directory")
print(function_def)
# {
#   "type": "function",
#   "function": {
#     "name": "list_directory",
#     "description": "...",
#     "parameters": {...}
#   }
# }
```

### Вызов инструмента:
```python
from openai import OpenAI

client = OpenAI(base_url="http://localhost:1234/v1")

# Получить все функции для агента
tools = registry.get_all_functions()

response = client.chat.completions.create(
    model="qwen3.5-35b",
    messages=[{"role": "user", "content": "Покажи файлы в проекте"}],
    tools=tools
)

# Проверить tool call
if response.choices[0].message.tool_calls:
    tool_call = response.choices[0].message.tool_calls[0]
    
    # Выполнить с safety checks
    result = registry.call(
        name=tool_call.function.name,
        **json.loads(tool_call.function.arguments)
    )
```

---

## 📊 Ожидаемые инструменты (начальный набор)

### 1. File System Tools (`file_system.py`)
- `list_directory(path: str)` - список файлов в директории
- `read_file(path: str, max_lines: int = 1000)` - чтение файла с лимитом строк
- `search_files(pattern: str)` - поиск файлов по паттерну

### 2. Network Tools (`network.py`)
- `http_get(url: str, headers: dict = {})` - GET запрос
- `http_post(url: str, data: dict) -> dict` - POST запрос
- `check_url_status(url: str)` - проверка доступности URL

### 3. Search Tools (`search.py`)
- `search_in_files(pattern: str, file_pattern: str = "*")` - поиск текста в файлах
- `git_log(limit: int = 10) -> List[str]` - последние коммиты git
- `find_file(name: str)` - найти файл по имени

### 4. Project Info Tools (`project_info.py`)
- `get_project_structure()` - структура проекта
- `count_lines(files: List[str])` - подсчет строк кода
- `get_recent_changes(hours: int = 24)` - изменения за последние часы

---

## 🧪 Unit Tests

### Тесты для ToolRegistry:
```python
def test_registry_registration():
    registry = ToolRegistry()
    
    @registry.register(name="test_func")
    def test_func(x: int) -> int:
        return x * 2
    
    assert "test_func" in registry.tools
    
def test_function_definition_generation():
    registry = ToolRegistry()
    
    function_def = registry.get_function_definition("list_directory")
    
    assert function_def["function"]["name"] == "list_directory"
    assert "description" in function_def["function"]
    assert "parameters" in function_def["function"]

def test_safety_checks():
    registry = ToolRegistry()
    
    # Попытка прочитать файл вне whitelist
    with pytest.raises(SecurityError):
        registry.call("read_file", path="/etc/passwd")
```

---

## 📦 Зависимости

```python
# requirements.txt
pydantic>=2.0.0
openai>=1.0.0
opentelemetry-api>=1.20.0
opentelemetry-sdk>=1.20.0
ratelimit>=2.2.1
```

---

## 🔄 Интеграция с существующей системой

### LangGraph Orchestrator:
```python
from tools import ToolRegistry

# В langgraph_orchestrator.py
registry = ToolRegistry()

def _get_tools_for_agent(agent_name: str) -> List[dict]:
    """Получить инструменты для конкретного агента"""
    agent_tools = AGENT_TOOL_MAPPING.get(agent_name, ["search", "file_system"])
    
    functions = []
    for tool_name in agent_tools:
        functions.extend(registry.get_all_functions())
    
    return functions

def _call_tool_with_context(state):
    """Вызов инструмента с контекстом из Qdrant"""
    # ... existing code ...
    result = registry.call(tool_name, **args)
    
    # Добавить в state для следующего шага
    state["tool_results"].append({
        "name": tool_name,
        "result": result,
        "timestamp": datetime.now()
    })
```

---

## 🎯 KPI и метрики успеха

### Для Фазы 1:
- [x] Все инструменты регистрируются автоматически
- [x] Function definitions генерируются корректно для LM Studio
- [x] Safety checks предотвращают небезопасные вызовы
- [x] Rate limiting работает корректно
- [x] Unit tests покрывают >80% кода

### Для системы в целом:
- ⏱️ latency вызова инструмента < 10ms
- 🔒 0 security incidents (все safety checks работают)
- 📈 покрытие unit tests > 80%

---

## 📅 План реализации (по дням)

| День | Задачи | Результат |
|------|--------|-----------|
| **День 1** | 1.1, 1.2, 1.3 | Базовая структура + декораторы |
| **День 2** | 1.4, 1.5 (file_system) | Safety checks + инструменты файлов |
| **День 3** | 1.5 (network, search), 1.6 | Все инструменты + интеграция LM Studio |
| **День 4** | 1.7 | Unit tests + документация |

---

## 🚦 Старт реализации

Готовы начать? Следующий шаг: создать структуру проекта и базовый класс `ToolRegistry`.
