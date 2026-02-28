"""
File System Tools
Инструменты для работы с файловой системой
"""

import os
from typing import List, Dict, Any
from ..types import ToolDefinition


class ListDirectoryTool:
    """Список файлов в директории"""
    
    name = "list_directory"
    description = "Получает список файлов и директорий в указанной папке"
    parameters = {
        "type": "object",
        "properties": {
            "path": {
                "type": "string",
                "description": "Путь к директории для просмотра"
            }
        },
        "required": ["path"]
    }
    
    @classmethod
    def execute(cls, path: str) -> List[str]:
        """
        Args:
            path: Путь к директории
            
        Returns:
            Список имен файлов и директорий
            
        Raises:
            PermissionError: Если нет доступа к директории
            FileNotFoundError: Если директория не найдена
        """
        if not os.path.exists(path):
            raise FileNotFoundError(f"Directory not found: {path}")
        
        if not os.path.isdir(path):
            raise ValueError(f"Not a directory: {path}")
        
        return os.listdir(path)


class ReadFileTool:
    """Чтение файла с лимитом строк"""
    
    name = "read_file"
    description = "Читает содержимое файла с ограничением по количеству строк"
    parameters = {
        "type": "object",
        "properties": {
            "path": {
                "type": "string",
                "description": "Путь к файлу для чтения"
            },
            "max_lines": {
                "type": "integer",
                "default": 1000,
                "description": "Максимальное количество строк для чтения (предотвращает перегрузку контекста)"
            }
        },
        "required": ["path"]
    }
    
    @classmethod
    def execute(cls, path: str, max_lines: int = 1000) -> Dict[str, Any]:
        """
        Args:
            path: Путь к файлу
            max_lines: Максимальное количество строк
            
        Returns:
            Dict с полями:
            - content: Содержимое файла (первые max_lines строк)
            - total_lines: Общее количество строк в файле
            - truncated: True если файл был усечен
            
        Raises:
            PermissionError: Если нет доступа к файлу
            FileNotFoundError: Если файл не найден
        """
        if not os.path.exists(path):
            raise FileNotFoundError(f"File not found: {path}")
        
        if not os.path.isfile(path):
            raise ValueError(f"Not a file: {path}")
        
        with open(path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        total_lines = len(lines)
        
        # Ограничиваем количество строк
        if total_lines > max_lines:
            content = ''.join(lines[:max_lines])
            truncated = True
        else:
            content = ''.join(lines)
            truncated = False
        
        return {
            "content": content,
            "total_lines": total_lines,
            "truncated": truncated,
            "path": path
        }


class SearchFilesTool:
    """Поиск файлов по паттерну"""
    
    name = "search_files"
    description = "Ищет файлы в директории по паттерну имени (поддерживает * и ?)"
    parameters = {
        "type": "object",
        "properties": {
            "pattern": {
                "type": "string",
                "description": "Паттерн поиска (* для любого количества символов, ? для одного символа)"
            },
            "path": {
                "type": "string",
                "default": ".",
                "description": "Корневая директория для поиска"
            },
            "recursive": {
                "type": "boolean",
                "default": True,
                "description": "Искать рекурсивно в поддиректориях"
            }
        },
        "required": ["pattern"]
    }
    
    @classmethod
    def execute(
        cls, 
        pattern: str, 
        path: str = ".", 
        recursive: bool = True
    ) -> List[str]:
        """
        Args:
            pattern: Паттерн поиска (например, "*.swift")
            path: Корневая директория
            recursive: Рекурсивный поиск
            
        Returns:
            Список полных путей к найденным файлам
        """
        import fnmatch
        
        results = []
        
        if recursive:
            for root, dirs, files in os.walk(path):
                for filename in files:
                    if fnmatch.fnmatch(filename, pattern):
                        full_path = os.path.join(root, filename)
                        results.append(full_path)
        else:
            for filename in os.listdir(path):
                if fnmatch.fnmatch(filename, pattern):
                    full_path = os.path.join(path, filename)
                    if os.path.isfile(full_path):
                        results.append(full_path)
        
        return results


class GetFileMetadataTool:
    """Получение метаданных файла"""
    
    name = "get_file_metadata"
    description = "Получает информацию о файле (размер, дата изменения, права доступа)"
    parameters = {
        "type": "object",
        "properties": {
            "path": {
                "type": "string",
                "description": "Путь к файлу"
            }
        },
        "required": ["path"]
    }
    
    @classmethod
    def execute(cls, path: str) -> Dict[str, Any]:
        """
        Args:
            path: Путь к файлу
            
        Returns:
            Dict с полями:
            - size_bytes: Размер файла в байтах
            - modified_time: Время последнего изменения (timestamp)
            - created_time: Время создания (timestamp)
            - is_executable: Файл является исполняемым
            - permissions: Права доступа (octal)
        """
        if not os.path.exists(path):
            raise FileNotFoundError(f"File not found: {path}")
        
        stat_info = os.stat(path)
        
        return {
            "size_bytes": stat_info.st_size,
            "modified_time": stat_info.st_mtime,
            "created_time": stat_info.st_ctime,
            "is_executable": bool(stat_info.st_mode & 0o111),
            "permissions": oct(stat_info.st_mode)[-3:],
            "path": path
        }


def get_file_system_tools() -> List[ToolDefinition]:
    """Получить все инструменты файловой системы
    
    Returns:
        Список ToolDefinition объектов
    """
    tools = [
        ListDirectoryTool,
        ReadFileTool,
        SearchFilesTool,
        GetFileMetadataTool
    ]
    
    return [
        ToolDefinition(
            function={
                "name": tool.name,
                "description": tool.description,
                "parameters": tool.parameters
            }
        )
        for tool in tools
    ]
