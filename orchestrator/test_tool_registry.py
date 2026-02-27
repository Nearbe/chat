"""
Unit Tests for Tool Registry
Тестирование Tool Registry и всех инструментов
"""

import os
import tempfile
import pytest
from orchestrator.tools import (
    ToolRegistry, 
    get_registry,
    RateLimitConfig,
    SafetyConfig,
    SafetyCheckType
)
from orchestrator.tools.types import ToolDefinition


class TestToolRegistry:
    """Тесты для ToolRegistry"""
    
    def setup_method(self):
        """Подготовка перед каждым тестом"""
        self.registry = ToolRegistry()
    
    def test_register_tool_with_decorator(self):
        """Тест регистрации инструмента через декоратор"""
        
        @self.registry.register(
            name="test_function",
            description="Test function for testing",
            parameters={
                "type": "object",
                "properties": {
                    "param1": {"type": "string"}
                },
                "required": ["param1"]
            }
        )
        def test_func(param1: str) -> str:
            return f"Hello {param1}"
        
        assert "test_function" in self.registry.tools
        
    def test_get_function_definition(self):
        """Тест получения function definition"""
        
        @self.registry.register(
            name="list_directory",
            description="List directory contents",
            parameters={
                "type": "object",
                "properties": {
                    "path": {"type": "string"}
                },
                "required": ["path"]
            }
        )
        def list_dir(path: str):
            return os.listdir(path)
        
        definition = self.registry.get_function_definition("list_directory")
        
        assert isinstance(definition, ToolDefinition)
        assert definition.function["name"] == "list_directory"
        assert definition.function["description"] == "List directory contents"
    
    def test_get_all_functions(self):
        """Тест получения всех function definitions"""
        
        @self.registry.register(name="tool1", description="Tool 1", parameters={})
        def tool1(): pass
        
        @self.registry.register(name="tool2", description="Tool 2", parameters={})
        def tool2(): pass
        
        all_functions = self.registry.get_all_functions()
        
        assert len(all_functions) == 2
    
    def test_call_nonexistent_tool(self):
        """Тест вызова несуществующего инструмента"""
        
        result = self.registry.call("nonexistent_tool")
        
        assert not result.success
        assert "not found" in result.error.lower()


class TestRateLimiter:
    """Тесты для rate limiting"""
    
    def test_rate_limit_exceeded(self):
        """Тест превышения лимита вызовов"""
        
        registry = ToolRegistry()
        
        @registry.register(
            name="rate_limited_tool",
            description="Tool with rate limit",
            parameters={}
        )
        def limited_func():
            return "OK"
        
        # Настраиваем строгий лимит: 2 вызова в секунду
        registry.add_rate_limiter(
            "rate_limited_tool", 
            RateLimitConfig(max_calls=2, window_seconds=1)
        )
        
        # Первые два вызова должны succeed
        result1 = registry.call("rate_limited_tool")
        result2 = registry.call("rate_limited_tool")
        
        assert result1.success
        assert result2.success
        
        # Третий должен быть ограничен
        import time
        time.sleep(0.1)  # Небольшая задержка
        result3 = registry.call("rate_limited_tool")
        
        assert not result3.success
        assert "Rate limit exceeded" in result3.error


class TestFileSystemTools:
    """Тесты для файловых инструментов"""
    
    def setup_method(self):
        """Создаем временные файлы для тестов"""
        self.temp_dir = tempfile.mkdtemp()
        
        # Создаем тестовые файлы
        self.test_file1 = os.path.join(self.temp_dir, "test1.txt")
        self.test_file2 = os.path.join(self.temp_dir, "test2.py")
        
        with open(self.test_file1, 'w') as f:
            f.write("Line 1\nLine 2\nLine 3\n")
        
        with open(self.test_file2, 'w') as f:
            f.write("#!/usr/bin/env python\nprint('Hello')\n")
    
    def test_list_directory(self):
        """Тест list_directory"""
        
        @self.registry.register(
            name="list_directory",
            description="List directory contents",
            parameters={
                "type": "object",
                "properties": {"path": {"type": "string"}},
                "required": ["path"]
            }
        )
        def list_dir(path: str):
            return os.listdir(path)
        
        result = self.registry.call("list_directory", path=self.temp_dir)
        
        assert result.success
        assert "test1.txt" in result.result
        assert "test2.py" in result.result
    
    def test_read_file(self):
        """Тест read_file"""
        
        @self.registry.register(
            name="read_file",
            description="Read file contents",
            parameters={
                "type": "object",
                "properties": {
                    "path": {"type": "string"},
                    "max_lines": {"type": "integer", "default": 100}
                },
                "required": ["path"]
            }
        )
        def read_file_func(path: str, max_lines: int = 100):
            with open(path, 'r') as f:
                return f.read()
        
        result = self.registry.call("read_file", path=self.test_file1)
        
        assert result.success
        assert "Line 1" in result.result
    
    def test_read_file_with_limit(self):
        """Тест read_file с ограничением строк"""
        
        @self.registry.register(
            name="read_file_limited",
            description="Read file with line limit",
            parameters={
                "type": "object",
                "properties": {
                    "path": {"type": "string"},
                    "max_lines": {"type": "integer"}
                },
                "required": ["path"]
            }
        )
        def read_limited(path: str, max_lines: int):
            with open(path, 'r') as f:
                lines = f.readlines()[:max_lines]
                return ''.join(lines)
        
        result = self.registry.call(
            "read_file_limited", 
            path=self.test_file1,
            max_lines=2
        )
        
        assert result.success
        lines = result.result.split('\n')
        assert len(lines) == 3  # Line 1, Line 2, empty


class TestSearchTools:
    """Тесты для инструментов поиска"""
    
    def setup_method(self):
        self.temp_dir = tempfile.mkdtemp()
        
        # Создаем файлы с тестовым контентом
        test_file = os.path.join(self.temp_dir, "search_test.py")
        with open(test_file, 'w') as f:
            f.write("# This is a comment\n")
            f.write("def hello():\n")
            f.write("    print('Hello World')\n")
    
    def test_search_in_files_pattern(self):
        """Тест поиска по паттерну"""
        
        @self.registry.register(
            name="search_files",
            description="Search files by pattern",
            parameters={
                "type": "object",
                "properties": {
                    "pattern": {"type": "string"},
                    "path": {"type": "string"}
                },
                "required": ["pattern"]
            }
        )
        def search(pattern: str, path: str = "."):
            import fnmatch
            results = []
            for root, dirs, files in os.walk(path):
                for filename in files:
                    if fnmatch.fnmatch(filename, pattern):
                        results.append(os.path.join(root, filename))
            return results
        
        result = self.registry.call("search_files", pattern="*.py", path=self.temp_dir)
        
        assert result.success
        assert len(result.result) > 0


class TestSafetyChecks:
    """Тесты для safety checks"""
    
    def test_path_validation(self):
        """Тест валидации путей"""
        
        @self.registry.register(
            name="restricted_file",
            description="File with restricted path",
            parameters={
                "type": "object",
                "properties": {"path": {"type": "string"}},
                "required": ["path"]
            }
        )
        def read_restricted(path: str):
            return open(path).read()
        
        # Настраиваем safety check для этого инструмента
        from orchestrator.tools import SafetyConfig
        
        self.registry._tools["restricted_file"].safety_checks = [
            SafetyConfig(
                check_type=SafetyCheckType.PATH_VALIDATION,
                config={
                    "allowed_paths": ["/nonexistent"],  # Запрещаем все пути
                    "blocked_extensions": []
                }
            )
        ]
        
        result = self.registry.call("restricted_file", path="/etc/passwd")
        
        assert not result.success


class TestIntegration:
    """Интеграционные тесты"""
    
    def test_full_workflow(self):
        """Полный рабочий процесс регистрации и вызова инструмента"""
        
        registry = ToolRegistry()
        
        # Регистрация
        @registry.register(
            name="greet",
            description="Greet someone",
            parameters={
                "type": "object",
                "properties": {"name": {"type": "string"}},
                "required": ["name"]
            }
        )
        def greet(name: str) -> str:
            return f"Hello, {name}!"
        
        # Получение определения
        definition = registry.get_function_definition("greet")
        assert definition.function["name"] == "greet"
        
        # Вызов инструмента
        result = registry.call("greet", name="World")
        assert result.success
        assert result.result == "Hello, World!"


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
