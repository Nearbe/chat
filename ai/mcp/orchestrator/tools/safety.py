"""
Safety Module
Безопасность и валидация для инструментов
"""

import os
from typing import List, Optional, Dict, Any


class PathValidator:
    """Валидатор путей файлов"""
    
    def __init__(self, allowed_paths: List[str] = None, blocked_extensions: List[str] = None):
        """
        Args:
            allowed_paths: Whitelist путей (если не указано - все пути разрешены)
            blocked_extensions: Запрещенные расширения файлов
        """
        self.allowed_paths = [os.path.abspath(p) for p in (allowed_paths or [])]
        self.blocked_extensions = [ext.lower().lstrip('.') for ext in (blocked_extensions or [])]
    
    def validate(self, path: str) -> bool:
        """
        Проверка пути файла
        
        Args:
            path: Путь к файлу
            
        Returns:
            True если путь разрешен
            
        Raises:
            PermissionError: Если путь запрещен
            ValueError: Если файл не существует
        """
        # Проверка существования файла
        if not os.path.exists(path):
            raise FileNotFoundError(f"File not found: {path}")
        
        abs_path = os.path.abspath(path)
        
        # Проверка whitelist путей (если указан)
        if self.allowed_paths and not any(abs_path.startswith(p) for p in self.allowed_paths):
            raise PermissionError(
                f"Path {path} is outside allowed paths: {[os.path.basename(p) for p in self.allowed_paths]}"
            )
        
        # Проверка расширений файлов
        ext = os.path.splitext(path)[1].lower().lstrip('.')
        if ext in self.blocked_extensions:
            raise PermissionError(f"Extension {ext} is blocked")
        
        return True


class URLValidator:
    """Валидатор URL"""
    
    def __init__(self, allowed_domains: List[str] = None):
        """
        Args:
            allowed_domains: Whitelist доменов (если не указано - все домены разрешены)
        """
        self.allowed_domains = [d.lower() for d in (allowed_domains or [])]
    
    def validate(self, url: str) -> bool:
        """
        Проверка URL
        
        Args:
            url: URL для проверки
            
        Returns:
            True если домен разрешен
            
        Raises:
            PermissionError: Если домен запрещен
            ValueError: Если URL некорректный
        """
        from urllib.parse import urlparse
        
        try:
            parsed = urlparse(url)
            
            if not parsed.scheme or not parsed.netloc:
                raise ValueError(f"Invalid URL format: {url}")
            
            domain = parsed.netloc.lower()
            
            # Проверка whitelist доменов (если указан)
            if self.allowed_domains and not any(domain.startswith(d) for d in self.allowed_domains):
                raise PermissionError(
                    f"Domain {domain} is not allowed. Allowed: {[os.path.basename(d) for d in self.allowed_domains]}"
                )
            
            return True
        
        except ValueError:
            raise
        except Exception as e:
            raise ValueError(f"Invalid URL: {url}") from e


class RateLimiter:
    """Rate limiter для ограничения вызовов"""
    
    def __init__(self, max_calls: int = 100, window_seconds: int = 3600):
        """
        Args:
            max_calls: Максимальное количество вызовов в окне
            window_seconds: Размер окна в секундах
        """
        import time
        
        self.max_calls = max_calls
        self.window_seconds = window_seconds
        self.calls: List[float] = []
    
    def is_allowed(self) -> bool:
        """
        Проверка можно ли выполнить вызов
        
        Returns:
            True если в лимитах
        """
        import time
        
        now = time.time()
        
        # Удаляем старые записи
        self.calls = [t for t in self.calls if now - t < self.window_seconds]
        
        if len(self.calls) < self.max_calls:
            self.calls.append(now)
            return True
        
        return False
    
    def wait_time(self) -> float:
        """Время ожидания до следующего разрешенного вызова"""
        import time
        
        if not self.calls:
            return 0.0
        
        now = time.time()
        oldest = self.calls[0]
        
        wait_time = (oldest + self.window_seconds) - now
        return max(0.0, wait_time)


class SafetyManager:
    """Менеджер безопасности для всех инструментов"""
    
    def __init__(self):
        self.path_validators: Dict[str, PathValidator] = {}
        self.url_validators: Dict[str, URLValidator] = {}
        self.rate_limiters: Dict[str, RateLimiter] = {}
    
    def configure_path_security(
        self, 
        tool_name: str,
        allowed_paths: List[str] = None,
        blocked_extensions: List[str] = None
    ):
        """Настроить безопасность для работы с файлами
        
        Args:
            tool_name: Имя инструмента
            allowed_paths: Whitelist путей
            blocked_extensions: Запрещенные расширения
        """
        self.path_validators[tool_name] = PathValidator(
            allowed_paths=allowed_paths,
            blocked_extensions=blocked_extensions
        )
    
    def configure_network_security(
        self, 
        tool_name: str,
        allowed_domains: List[str] = None
    ):
        """Настроить безопасность для сетевых инструментов
        
        Args:
            tool_name: Имя инструмента
            allowed_domains: Whitelist доменов
        """
        self.url_validators[tool_name] = URLValidator(allowed_domains=allowed_domains)
    
    def configure_rate_limiting(
        self, 
        tool_name: str,
        max_calls: int = 100,
        window_seconds: int = 3600
    ):
        """Настроить rate limiting для инструмента
        
        Args:
            tool_name: Имя инструмента
            max_calls: Максимум вызовов в окне
            window_seconds: Размер окна в секундах
        """
        self.rate_limiters[tool_name] = RateLimiter(
            max_calls=max_calls,
            window_seconds=window_seconds
        )
    
    def validate_path(self, tool_name: str, path: str) -> bool:
        """Валидация пути для инструмента
        
        Args:
            tool_name: Имя инструмента
            path: Путь к файлу
            
        Returns:
            True если путь разрешен
            
        Raises:
            PermissionError: Если путь запрещен
        """
        if tool_name in self.path_validators:
            return self.path_validators[tool_name].validate(path)
        
        # Если валидатор не настроен - проверяем базовые вещи
        if not os.path.exists(path):
            raise FileNotFoundError(f"File not found: {path}")
        
        return True
    
    def validate_url(self, tool_name: str, url: str) -> bool:
        """Валидация URL для инструмента
        
        Args:
            tool_name: Имя инструмента
            url: URL
            
        Returns:
            True если домен разрешен
            
        Raises:
            PermissionError: Если домен запрещен
        """
        if tool_name in self.url_validators:
            return self.url_validators[tool_name].validate(url)
        
        # Если валидатор не настроен - URL считается разрешенным
        return True
    
    def check_rate_limit(self, tool_name: str) -> bool:
        """Проверка rate limiting
        
        Args:
            tool_name: Имя инструмента
            
        Returns:
            True если вызов разрешен
        """
        if tool_name in self.rate_limiters:
            return self.rate_limiters[tool_name].is_allowed()
        
        # Если rate limiter не настроен - пропускаем
        return True


# Глобальный менеджер безопасности
_safety_manager = None


def get_safety_manager() -> SafetyManager:
    """Получить глобальный экземпляр менеджера безопасности"""
    global _safety_manager
    if _safety_manager is None:
        _safety_manager = SafetyManager()
    
    # Настройка по умолчанию для популярных инструментов
    if not _safety_manager.path_validators:
        _safety_manager.configure_path_security(
            tool_name="read_file",
            allowed_paths=[
                "/Users/nearbe/repositories/Chat"
            ],
            blocked_extensions=[".env", ".pem", ".key", ".secret"]
        )
    
    if not _safety_manager.rate_limiters:
        _safety_manager.configure_rate_limiting(
            tool_name="http_get",
            max_calls=60,
            window_seconds=3600  # 60 вызовов в час
        )
    
    return _safety_manager
