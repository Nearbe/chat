"""
Tool Registry - Центральный реестр инструментов для агентов

Пример использования:

```python
from tools import ToolRegistry, get_registry

# Использование глобального реестра
registry = get_registry()

@registry.register(name="list_directory")
def list_directory(path: str) -> List[str]:
    """Список файлов в директории"""
    return os.listdir(path)

# Получить определение для LM Studio
definition = registry.get_function_definition("list_directory")

# Вызвать инструмент
result = registry.call("list_directory", path="/Users/nearbe/repositories/Chat")
```
"""

from .registry import ToolRegistry, get_registry, Registry
from .types import (
    ToolDefinition,
    ToolMetadata,
    ToolCallResult,
    RateLimitConfig,
    SafetyConfig,
    SafetyCheckType
)
from .tools.base import BaseTool, FileSystemTool, NetworkTool

__all__ = [
    # Основной API
    "ToolRegistry",
    "get_registry",
    "Registry",
    
    # Типы данных
    "ToolDefinition",
    "ToolMetadata",
    "ToolCallResult",
    "RateLimitConfig",
    "SafetyConfig",
    "SafetyCheckType",
    
    # Базовые классы для создания инструментов
    "BaseTool",
    "FileSystemTool",
    "NetworkTool"
]
