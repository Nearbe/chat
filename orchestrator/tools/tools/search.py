"""
Search Tools
Инструменты для поиска в проекте и git
"""

import os
import re
from typing import List, Dict, Any
from ..types import ToolDefinition


class SearchInFilesTool:
    """Поиск текста в файлах проекта"""
    
    name = "search_in_files"
    description = "Ищет текст или паттерн в содержимом файлов проекта"
    parameters = {
        "type": "object",
        "properties": {
            "pattern": {
                "type": "string",
                "description": "Текст или регулярное выражение для поиска"
            },
            "file_pattern": {
                "type": "string",
                "default": "*",
                "description": "Паттерн имен файлов (например, '*.swift')"
            },
            "path": {
                "type": "string",
                "default": ".",
                "description": "Корневая директория для поиска"
            },
            "max_results": {
                "type": "integer",
                "default": 20,
                "description": "Максимальное количество результатов"
            }
        },
        "required": ["pattern"]
    }
    
    @classmethod
    def execute(
        cls, 
        pattern: str,
        file_pattern: str = "*",
        path: str = ".",
        max_results: int = 20
    ) -> List[Dict[str, Any]]:
        """
        Args:
            pattern: Текст или regex для поиска
            file_pattern: Паттерн имен файлов
            path: Корневая директория
            max_results: Максимум результатов
            
        Returns:
            Список Dict с полями:
            - file: Имя файла
            - line_number: Номер строки
            - content: Содержимое строки с выделением
            - match_context: Контекст вокруг совпадения
        """
        import fnmatch
        
        results = []
        
        try:
            # Попытка компилировать regex
            try:
                regex = re.compile(pattern)
                is_regex = True
            except re.error:
                regex = None
                is_regex = False
            
            for root, dirs, files in os.walk(path):
                for filename in files:
                    if fnmatch.fnmatch(filename, file_pattern):
                        filepath = os.path.join(root, filename)
                        
                        try:
                            with open(filepath, 'r', encoding='utf-8') as f:
                                lines = f.readlines()
                                
                                for line_num, line in enumerate(lines, 1):
                                    if is_regex and regex.search(line):
                                        results.append({
                                            "file": filepath,
                                            "line_number": line_num,
                                            "content": line.strip(),
                                            "match_context": regex.search(line).group()
                                        })
                                    
                                    elif not is_regex and pattern in line:
                                        results.append({
                                            "file": filepath,
                                            "line_number": line_num,
                                            "content": line.strip(),
                                            "match_context": pattern
                                        })
                                    
                                    if len(results) >= max_results:
                                        return results
                        
                        except (IOError, UnicodeDecodeError):
                            # Пропускаем бинарные файлы и файлы с кодировкой
                            continue
        
        except Exception as e:
            return [{"error": str(e)}]
        
        return results[:max_results]


class GitLogTool:
    """Получение последних коммитов git"""
    
    name = "git_log"
    description = "Получает последние коммиты из git истории проекта"
    parameters = {
        "type": "object",
        "properties": {
            "limit": {
                "type": "integer",
                "default": 10,
                "description": "Количество последних коммитов"
            },
            "path": {
                "type": "string",
                "default": ".",
                "description": "Путь к репозиторию git"
            }
        },
        "required": []
    }
    
    @classmethod
    def execute(
        cls, 
        limit: int = 10, 
        path: str = "."
    ) -> List[Dict[str, Any]]:
        """
        Args:
            limit: Количество коммитов
            path: Путь к git репозиторию
            
        Returns:
            Список Dict с полями:
            - hash: Хэш коммита (короткий)
            - author: Автор коммита
            - date: Дата коммита
            - message: Сообщение коммита
        """
        import subprocess
        
        try:
            result = subprocess.run(
                ["git", "log", f"-{limit}", "--pretty=format:%h|%an|%ad|%s"],
                cwd=path,
                capture_output=True,
                text=True,
                timeout=10
            )
            
            if result.returncode != 0:
                return [{"error": "Not a git repository"}]
            
            commits = []
            for line in result.stdout.strip().split('\n'):
                parts = line.split('|', 3)
                if len(parts) == 4:
                    commits.append({
                        "hash": parts[0],
                        "author": parts[1],
                        "date": parts[2],
                        "message": parts[3]
                    })
            
            return commits
        
        except subprocess.TimeoutExpired:
            return [{"error": "Git command timeout"}]
        
        except Exception as e:
            return [{"error": str(e)}]


class FindFileTool:
    """Поиск файла по имени"""
    
    name = "find_file"
    description = "Ищет файл по имени или части имени в проекте"
    parameters = {
        "type": "object",
        "properties": {
            "name": {
                "type": "string",
                "description": "Имя файла для поиска (поддерживает *)"
            },
            "path": {
                "type": "string",
                "default": ".",
                "description": "Корневая директория"
            }
        },
        "required": ["name"]
    }
    
    @classmethod
    def execute(
        cls, 
        name: str, 
        path: str = "."
    ) -> List[str]:
        """
        Args:
            name: Имя файла (с поддержкой wildcards)
            path: Корневая директория
            
        Returns:
            Список полных путей к найденным файлам
        """
        import fnmatch
        
        results = []
        
        for root, dirs, files in os.walk(path):
            for filename in files:
                if fnmatch.fnmatch(filename.lower(), name.lower()):
                    full_path = os.path.join(root, filename)
                    results.append(full_path)
                    
                    # Ограничиваем количество результатов
                    if len(results) >= 50:
                        break
            
            if len(results) >= 50:
                break
        
        return results


class GetProjectStructureTool:
    """Получение структуры проекта"""
    
    name = "get_project_structure"
    description = "Выводит структуру директорий проекта с количеством файлов"
    parameters = {
        "type": "object",
        "properties": {
            "path": {
                "type": "string",
                "default": ".",
                "description": "Корневая директория"
            },
            "max_depth": {
                "type": "integer",
                "default": 3,
                "description": "Максимальная глубина рекурсии"
            }
        },
        "required": []
    }
    
    @classmethod
    def execute(
        cls, 
        path: str = ".",
        max_depth: int = 3
    ) -> Dict[str, Any]:
        """
        Args:
            path: Корневая директория
            max_depth: Максимальная глубина
            
        Returns:
            Структура проекта в формате:
            {
                "total_files": int,
                "total_dirs": int,
                "structure": [...],
                "file_types": {...}
            }
        """
        def get_dir_structure(current_path: str, depth: int = 0) -> Dict[str, Any]:
            if depth > max_depth:
                return {}
            
            try:
                entries = os.listdir(current_path)
            except PermissionError:
                return {"error": "Permission denied"}
            
            structure = {
                "name": os.path.basename(current_path),
                "path": current_path,
                "files": [],
                "directories": {}
            }
            
            for entry in entries:
                full_path = os.path.join(current_path, entry)
                
                if os.path.isfile(full_path):
                    structure["files"].append({
                        "name": entry,
                        "size_bytes": os.path.getsize(full_path),
                        "extension": os.path.splitext(entry)[1]
                    })
                elif os.path.isdir(full_path):
                    structure["directories"][entry] = get_dir_structure(
                        full_path, 
                        depth + 1
                    )
            
            return structure
        
        result = {
            "total_files": 0,
            "total_dirs": 0,
            "structure": get_dir_structure(path),
            "file_types": {}
        }
        
        # Подсчет типов файлов
        for item in os.walk(path):
            root, dirs, files = item
            for file in files:
                ext = os.path.splitext(file)[1].lower() or "no_extension"
                result["file_types"][ext] = result["file_types"].get(ext, 0) + 1
        
        # Подсчет общего количества файлов и директорий
        def count_items(dir_path):
            try:
                items = os.listdir(dir_path)
                for item in items:
                    full_path = os.path.join(dir_path, item)
                    if os.path.isfile(full_path):
                        result["total_files"] += 1
                    elif os.path.isdir(full_path):
                        result["total_dirs"] += 1
                        count_items(full_path)
            except PermissionError:
                pass
        
        count_items(path)
        
        return result


def get_search_tools() -> List[ToolDefinition]:
    """Получить все инструменты поиска
    
    Returns:
        Список ToolDefinition объектов
    """
    tools = [
        SearchInFilesTool,
        GitLogTool,
        FindFileTool,
        GetProjectStructureTool
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
