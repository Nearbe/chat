"""
Types for Tool Registry
Pydantic models для описания инструментов и их параметров
"""

from pydantic import BaseModel, Field
from typing import Optional, Dict, List, Any
from enum import Enum


class SafetyCheckType(str, Enum):
    """Типы安全检查"""
    PATH_VALIDATION = "path_validation"
    URL_VALIDATION = "url_validation"
    RATE_LIMITING = "rate_limiting"
    TIMEOUT = "timeout"
    SIZE_LIMIT = "size_limit"


class RateLimitConfig(BaseModel):
    """Конфигурация rate limiting"""
    max_calls: int = Field(..., description="Максимальное количество вызовов")
    window_seconds: int = Field(..., description="Временное окно в секундах")
    
    class Config:
        json_schema_extra = {
            "example": {
                "max_calls": 100,
                "window_seconds": 3600
            }
        }


class SafetyConfig(BaseModel):
    """Конфигурация безопасности для инструмента"""
    check_type: SafetyCheckType
    config: Dict[str, Any] = Field(default_factory=dict)
    
    class Config:
        json_schema_extra = {
            "example": {
                "check_type": "path_validation",
                "config": {
                    "allowed_paths": ["/Users/nearbe/repositories/Chat"],
                    "blocked_extensions": [".env", ".pem"]
                }
            }
        }


class ToolDefinition(BaseModel):
    """Определение инструмента для LM Studio"""
    type: str = Field(default="function", const=True)
    function: Dict[str, Any] = Field(
        ..., 
        description="Функция с именем, описанием и параметрами"
    )
    
    class Config:
        json_schema_extra = {
            "example": {
                "type": "function",
                "function": {
                    "name": "get_file_content",
                    "description": "Читает содержимое файла по пути",
                    "parameters": {
                        "type": "object",
                        "properties": {
                            "path": {"type": "string"}
                        },
                        "required": ["path"]
                    }
                }
            }
        }


class ToolMetadata(BaseModel):
    """Метаданные инструмента"""
    name: str = Field(..., description="Имя инструмента")
    description: str = Field(..., description="Описание функции инструмента")
    parameters: Dict[str, Any] = Field(
        ..., 
        description="JSON schema параметров"
    )
    required: List[str] = Field(default_factory=list)
    safety_checks: List[SafetyConfig] = Field(default_factory=list)
    rate_limit: Optional[RateLimitConfig] = None
    
    class Config:
        json_schema_extra = {
            "example": {
                "name": "list_directory",
                "description": "Список файлов в директории",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "path": {"type": "string"}
                    },
                    "required": ["path"]
                },
                "required": ["path"],
                "safety_checks": [
                    {
                        "check_type": "path_validation",
                        "config": {
                            "allowed_paths": ["/Users/nearbe/repositories/Chat"]
                        }
                    }
                ]
            }
        }


class ToolCallResult(BaseModel):
    """Результат вызова инструмента"""
    success: bool = Field(..., description="Успешно ли выполнен вызов")
    result: Optional[Any] = Field(None, description="Результат выполнения")
    error: Optional[str] = Field(None, description="Ошибка если возникла")
    execution_time_ms: Optional[float] = Field(
        None, 
        description="Время выполнения в миллисекундах"
    )
    tool_name: str = Field(..., description="Имя вызванного инструмента")
    
    class Config:
        json_schema_extra = {
            "example": {
                "success": True,
                "result": ["file1.py", "file2.swift"],
                "execution_time_ms": 5.2,
                "tool_name": "list_directory"
            }
        }
