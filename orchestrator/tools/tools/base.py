"""
Base tool class
Базовый класс для всех инструментов в реестре
"""

from abc import ABC, abstractmethod
import time
from typing import Any, Dict
from ..types import ToolDefinition


class BaseTool(ABC):
    """Базовый класс для всех инструментов
    
    Все инструменты должны наследовать этот класс и реализовать:
    - name: имя инструмента (используется для вызова)
    - description: описание функции
    - parameters: JSON schema параметров
    - execute(): метод выполнения
    """
    
    @property
    @abstractmethod
    def name(self) -> str:
        """Имя инструмента"""
        pass
    
    @property
    @abstractmethod
    def description(self) -> str:
        """Описание функции инструмента"""
        pass
    
    @property
    @abstractmethod
    def parameters(self) -> Dict[str, Any]:
        """JSON schema параметров инструмента"""
        pass
    
    @abstractmethod
    def execute(self, **kwargs) -> Any:
        """Выполнить инструмент с переданными параметрами
        
        Args:
            **kwargs: Параметры инструмента
            
        Returns:
            Результат выполнения
            
        Raises:
            Exception: Если выполнение не удалось
        """
        pass
    
    def get_definition(self) -> ToolDefinition:
        """Получить определение инструмента для LM Studio
        
        Returns:
            ToolDefinition объект в формате OpenAI/LM Studio
        """
        return ToolDefinition(
            function={
                "name": self.name,
                "description": self.description,
                "parameters": self.parameters
            }
        )
    
    def validate_parameters(self, **kwargs) -> bool:
        """Валидация параметров перед выполнением
        
        Args:
            **kwargs: Параметры
            
        Returns:
            True если параметры валидны
        """
        # Переопределить в подклассах для кастомной валидации
        return True
    
    async def execute_async(self, **kwargs) -> Any:
        """Асинхронное выполнение инструмента
        
        Args:
            **kwargs: Параметры
            
        Returns:
            Результат выполнения
        """
        # Переопределить для асинхронных операций
        return self.execute(**kwargs)


class FileSystemTool(BaseTool):
    """Базовый класс для инструментов файловой системы"""
    
    def __init__(self, allowed_paths=None, blocked_extensions=None):
        """
        Args:
            allowed_paths: Whitelist путей для доступа
            blocked_extensions: Запрещенные расширения файлов
        """
        self.allowed_paths = allowed_paths or []
        self.blocked_extensions = blocked_extensions or []
    
    def validate_path(self, path: str) -> bool:
        """Валидация пути файла
        
        Args:
            path: Путь к файлу
            
        Returns:
            True если путь разрешен
        """
        if not self.allowed_paths:
            return True  # Если whitelist пустой - разрешаем все
        
        import os
        abs_path = os.path.abspath(path)
        
        for allowed in self.allowed_paths:
            abs_allowed = os.path.abspath(allowed)
            if abs_path.startswith(abs_allowed):
                return True
        
        raise PermissionError(f"Path {path} is not in allowed paths")
    
    def validate_extension(self, path: str) -> bool:
        """Валидация расширения файла
        
        Args:
            path: Путь к файлу
            
        Returns:
            True если расширение разрешено
        """
        import os
        ext = os.path.splitext(path)[1].lower()
        
        if self.blocked_extensions and ext in [e.lower() for e in self.blocked_extensions]:
            raise PermissionError(f"Extension {ext} is blocked")
        
        return True


class NetworkTool(BaseTool):
    """Базовый класс для сетевых инструментов"""
    
    def __init__(self, allowed_domains=None, max_request_size=1024*1024):
        """
        Args:
            allowed_domains: Whitelist доменов для HTTP запросов
            max_request_size: Максимальный размер запроса в байтах
        """
        self.allowed_domains = allowed_domains or []
        self.max_request_size = max_request_size
    
    def validate_url(self, url: str) -> bool:
        """Валидация URL
        
        Args:
            url: URL для проверки
            
        Returns:
            True если домен разрешен
        """
        from urllib.parse import urlparse
        
        parsed = urlparse(url)
        domain = parsed.netloc.lower()
        
        if not self.allowed_domains:
            return True  # Если whitelist пустой - разрешаем все
        
        for allowed in self.allowed_domains:
            if allowed in domain:
                return True
        
        raise PermissionError(f"Domain {domain} is not in allowed domains")
