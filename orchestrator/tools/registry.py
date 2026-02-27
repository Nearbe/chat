"""
Tool Registry
Централизованный реестр для регистрации и управления инструментами
"""

import time
from collections import defaultdict, deque
from typing import Any, Callable, Dict, List, Optional
from .types import (
    ToolDefinition, 
    ToolMetadata, 
    ToolCallResult,
    RateLimitConfig,
    SafetyConfig
)


class RateLimiter:
    """Rate limiter для ограничения вызовов инструментов"""
    
    def __init__(self, max_calls: int, window_seconds: int):
        self.max_calls = max_calls
        self.window_seconds = window_seconds
        self.calls: deque = deque()
    
    def is_allowed(self) -> bool:
        """Проверить можно ли выполнить вызов
        
        Returns:
            True если в лимитах
        """
        now = time.time()
        
        # Удаляем старые записи за пределами окна
        while self.calls and now - self.calls[0] > self.window_seconds:
            self.calls.popleft()
        
        if len(self.calls) < self.max_calls:
            self.calls.append(now)
            return True
        
        return False
    
    def get_wait_time(self) -> float:
        """Получить время ожидания до следующего разрешенного вызова"""
        if not self.calls:
            return 0.0
        
        now = time.time()
        oldest = self.calls[0]
        
        wait_time = (oldest + self.window_seconds) - now
        return max(0.0, wait_time)


class ToolRegistry:
    """Центральный реестр инструментов
    
    Пример использования:
    
    ```python
    registry = ToolRegistry()
    
    @registry.register(name="my_tool")
    def my_tool_func(param: str) -> str:
        return f"Hello {param}"
    
    # Получить определение для LM Studio
    definition = registry.get_function_definition("my_tool")
    
    # Вызвать инструмент с safety checks
    result = registry.call("my_tool", param="World")
    ```
    """
    
    def __init__(self):
        """Инициализация реестра"""
        self._tools: Dict[str, ToolMetadata] = {}
        self._rate_limiters: Dict[str, RateLimiter] = {}
        self._call_history: Dict[str, deque] = defaultdict(lambda: deque(maxlen=100))
    
    @property
    def tools(self) -> Dict[str, ToolMetadata]:
        """Получить все зарегистрированные инструменты"""
        return self._tools
    
    def register(
        self, 
        name: Optional[str] = None,
        description: str = "",
        parameters: Dict[str, Any] = {},
        required: List[str] = None,
        rate_limit: Optional[RateLimitConfig] = None,
        safety_checks: List[SafetyConfig] = None
    ):
        """Декоратор для регистрации инструмента
        
        Args:
            name: Имя инструмента (если не указано - используется имя функции)
            description: Описание функции
            parameters: JSON schema параметров
            required: Список обязательных параметров
            rate_limit: Конфигурация rate limiting
            safety_checks: Списки安全检查
            
        Returns:
            Декоратор для регистрации функции
        
        Example:
            
            @registry.register(name="get_file_content")
            def read_file(path: str) -> str:
                with open(path, 'r') as f:
                    return f.read()
        """
        
        def decorator(func: Callable) -> Callable:
            tool_name = name or func.__name__
            
            # Сохраняем функцию в метаданные
            metadata = ToolMetadata(
                name=tool_name,
                description=description,
                parameters=parameters,
                required=required or [],
                rate_limit=rate_limit,
                safety_checks=safety_checks or []
            )
            
            self._tools[tool_name] = metadata
            
            # Настройка rate limiter если указан
            if rate_limit:
                self.add_rate_limiter(tool_name, rate_limit)
            
            return func
        
        return decorator
    
    def add_function(self, name: str, func: Callable):
        """Добавить функцию как инструмент (альтернатива декоратору)
        
        Args:
            name: Имя инструмента
            func: Функция для добавления
        """
        self._tools[name] = ToolMetadata(
            name=name,
            description=func.__doc__ or "",
            parameters={},  # Будет автоматически определено позже
            required=[]
        )
    
    def add_rate_limiter(self, tool_name: str, config: RateLimitConfig):
        """Добавить rate limiter для инструмента
        
        Args:
            tool_name: Имя инструмента
            config: Конфигурация rate limiting
        """
        self._rate_limiters[tool_name] = RateLimiter(
            max_calls=config.max_calls,
            window_seconds=config.window_seconds
        )
    
    def get_function_definition(self, tool_name: str) -> Optional[ToolDefinition]:
        """Получить определение инструмента для LM Studio
        
        Args:
            tool_name: Имя инструмента
            
        Returns:
            ToolDefinition или None если не найден
        """
        if tool_name not in self._tools:
            return None
        
        metadata = self._tools[tool_name]
        
        return ToolDefinition(
            function={
                "name": metadata.name,
                "description": metadata.description,
                "parameters": metadata.parameters
            }
        )
    
    def get_all_functions(self) -> List[ToolDefinition]:
        """Получить определения всех инструментов
        
        Returns:
            Список ToolDefinition объектов
        """
        return [self.get_function_definition(name) for name in self._tools]
    
    def call(
        self, 
        tool_name: str, 
        timeout_seconds: int = 30,
        **kwargs
    ) -> ToolCallResult:
        """Вызвать инструмент с safety checks
        
        Args:
            tool_name: Имя инструмента
            timeout_seconds: Таймаут выполнения в секундах
            **kwargs: Параметры для вызова
            
        Returns:
            ToolCallResult с результатом или ошибкой
        """
        import inspect
        from functools import wraps
        
        start_time = time.time()
        
        # Проверка существования инструмента
        if tool_name not in self._tools:
            return ToolCallResult(
                success=False,
                error=f"Tool '{tool_name}' not found",
                tool_name=tool_name
            )
        
        metadata = self._tools[tool_name]
        
        # Проверка rate limiting
        if tool_name in self._rate_limiters:
            limiter = self._rate_limiters[tool_name]
            if not limiter.is_allowed():
                wait_time = limiter.get_wait_time()
                return ToolCallResult(
                    success=False,
                    error=f"Rate limit exceeded. Wait {wait_time:.1f}s",
                    tool_name=tool_name
                )
        
        # Валидация параметров
        if not metadata.parameters:
            # Автоматическая генерация параметров из сигнатуры функции
            pass  # TODO: реализовать auto-detection
        
        try:
            # Поиск функции в модуле (будет реализовано ниже)
            func = self._get_function_by_name(tool_name)
            
            if not func:
                return ToolCallResult(
                    success=False,
                    error=f"Function '{tool_name}' not found",
                    tool_name=tool_name
                )
            
            # Выполнение с таймаутом
            result = self._execute_with_timeout(func, timeout_seconds, **kwargs)
            
            execution_time = (time.time() - start_time) * 1000
            
            return ToolCallResult(
                success=True,
                result=result,
                execution_time_ms=execution_time,
                tool_name=tool_name
            )
        
        except Exception as e:
            return ToolCallResult(
                success=False,
                error=str(e),
                tool_name=tool_name
            )
    
    def _get_function_by_name(self, name: str) -> Optional[Callable]:
        """Получить функцию по имени из реестра
        
        TODO: Реализовать поиск функции в зарегистрированных модулях
        """
        # Для текущего этапа - просто возвращаем None
        # В полной реализации будет поиск по всем загруженным модулям
        return None
    
    def _execute_with_timeout(
        self, 
        func: Callable, 
        timeout_seconds: int, 
        **kwargs
    ) -> Any:
        """Выполнить функцию с таймаутом"""
        # TODO: реализовать асинхронный timeout
        return func(**kwargs)


# Глобальный экземпляр реестра для удобного использования
_registry_instance = None


def get_registry() -> ToolRegistry:
    """Получить глобальный экземпляр реестра"""
    global _registry_instance
    if _registry_instance is None:
        _registry_instance = ToolRegistry()
    return _registry_instance


class Registry:
    """Альтернативный API для регистрации через декоратор
    
    Example:
    
    ```python
    registry = Registry()
    
    @registry.tool(name="get_file_content")
    def read_file(path: str) -> str:
        return open(path).read()
    ```
    """
    
    def __init__(self):
        self._tools: Dict[str, Callable] = {}
        self._definitions: Dict[str, Dict[str, Any]] = {}
    
    @property
    def tools(self) -> Dict[str, Callable]:
        return self._tools
    
    @property
    def definitions(self) -> Dict[str, Dict[str, Any]]:
        return self._definitions
    
    def tool(
        self, 
        name: Optional[str] = None,
        description: str = "",
        parameters: Dict[str, Any] = {}
    ):
        """Декоратор для регистрации инструмента
        
        Args:
            name: Имя инструмента (если не указано - имя функции)
            description: Описание функции
            parameters: JSON schema параметров
            
        Returns:
            Декоратор
        """
        
        def decorator(func: Callable) -> Callable:
            tool_name = name or func.__name__
            
            self._tools[tool_name] = func
            self._definitions[tool_name] = {
                "name": tool_name,
                "description": description,
                "parameters": parameters
            }
            
            return func
        
        return decorator
