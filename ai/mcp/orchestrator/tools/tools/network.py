"""
Network Tools
Инструменты для сетевых операций и HTTP запросов
"""

import json
from typing import Dict, Any, Optional
from ..types import ToolDefinition


class HTTPGetTool:
    """GET HTTP запрос"""
    
    name = "http_get"
    description = "Выполняет GET запрос к указанному URL"
    parameters = {
        "type": "object",
        "properties": {
            "url": {
                "type": "string",
                "description": "URL для GET запроса"
            },
            "headers": {
                "type": "object",
                "default": {},
                "description": "Кастомные заголовки запроса"
            }
        },
        "required": ["url"]
    }
    
    @classmethod
    def execute(
        cls, 
        url: str, 
        headers: Optional[Dict[str, str]] = None
    ) -> Dict[str, Any]:
        """
        Args:
            url: URL для GET запроса
            headers: Кастомные заголовки
            
        Returns:
            Dict с полями:
            - status_code: HTTP статус код
            - response_text: Ответ сервера как строка
            - headers: Response заголовки
            - success: True если запрос успешен (2xx)
            
        Raises:
            Exception: Если запрос не удался
        """
        import urllib.request
        import urllib.error
        
        request_headers = headers or {}
        
        try:
            req = urllib.request.Request(url, headers=request_headers)
            
            with urllib.request.urlopen(req, timeout=30) as response:
                status_code = response.status
                response_text = response.read().decode('utf-8')
                response_headers = dict(response.headers)
                
                return {
                    "status_code": status_code,
                    "response_text": response_text,
                    "headers": response_headers,
                    "success": 200 <= status_code < 300,
                    "url": url
                }
        
        except urllib.error.HTTPError as e:
            return {
                "status_code": e.code,
                "response_text": str(e.read().decode('utf-8')) if e.read else "",
                "headers": dict(e.headers),
                "success": False,
                "url": url,
                "error": str(e)
            }
        
        except Exception as e:
            return {
                "status_code": 0,
                "response_text": "",
                "success": False,
                "url": url,
                "error": str(e)
            }


class HTTPPostTool:
    """POST HTTP запрос"""
    
    name = "http_post"
    description = "Выполняет POST запрос с JSON телом к указанному URL"
    parameters = {
        "type": "object",
        "properties": {
            "url": {
                "type": "string",
                "description": "URL для POST запроса"
            },
            "data": {
                "type": "object",
                "description": "JSON данные для отправки"
            },
            "headers": {
                "type": "object",
                "default": {"Content-Type": "application/json"},
                "description": "Кастомные заголовки запроса"
            }
        },
        "required": ["url", "data"]
    }
    
    @classmethod
    def execute(
        cls, 
        url: str, 
        data: Dict[str, Any],
        headers: Optional[Dict[str, str]] = None
    ) -> Dict[str, Any]:
        """
        Args:
            url: URL для POST запроса
            data: Данные для отправки
            headers: Кастомные заголовки
            
        Returns:
            Dict с полями (см. HTTPGetTool)
        """
        import urllib.request
        import urllib.error
        
        request_headers = headers or {"Content-Type": "application/json"}
        json_data = json.dumps(data).encode('utf-8')
        
        try:
            req = urllib.request.Request(
                url, 
                data=json_data,
                headers=request_headers,
                method='POST'
            )
            
            with urllib.request.urlopen(req, timeout=30) as response:
                status_code = response.status
                response_text = response.read().decode('utf-8')
                
                return {
                    "status_code": status_code,
                    "response_text": response_text,
                    "success": 200 <= status_code < 300,
                    "url": url
                }
        
        except urllib.error.HTTPError as e:
            return {
                "status_code": e.code,
                "response_text": str(e.read().decode('utf-8')) if e.read else "",
                "success": False,
                "url": url,
                "error": str(e)
            }
        
        except Exception as e:
            return {
                "status_code": 0,
                "response_text": "",
                "success": False,
                "url": url,
                "error": str(e)
            }


class CheckURLStatusTool:
    """Проверка доступности URL"""
    
    name = "check_url_status"
    description = "Проверяет статус и время отклика URL"
    parameters = {
        "type": "object",
        "properties": {
            "url": {
                "type": "string",
                "description": "URL для проверки"
            },
            "timeout": {
                "type": "integer",
                "default": 10,
                "description": "Таймаут в секундах"
            }
        },
        "required": ["url"]
    }
    
    @classmethod
    def execute(
        cls, 
        url: str, 
        timeout: int = 10
    ) -> Dict[str, Any]:
        """
        Args:
            url: URL для проверки
            timeout: Таймаут в секундах
            
        Returns:
            Dict с полями:
            - reachable: True если URL доступен
            - status_code: HTTP статус код или 0
            - response_time_ms: Время отклика в миллисекундах
        """
        import urllib.request
        import time
        
        try:
            start = time.time()
            
            req = urllib.request.Request(url, method='HEAD')
            
            with urllib.request.urlopen(req, timeout=timeout) as response:
                response_time = (time.time() - start) * 1000
                
                return {
                    "reachable": True,
                    "status_code": response.status,
                    "response_time_ms": round(response_time, 2),
                    "url": url
                }
        
        except urllib.error.HTTPError as e:
            return {
                "reachable": False,
                "status_code": e.code,
                "error": str(e),
                "url": url
            }
        
        except Exception as e:
            return {
                "reachable": False,
                "status_code": 0,
                "error": str(e),
                "url": url
            }


def get_network_tools() -> List[ToolDefinition]:
    """Получить все сетевые инструменты
    
    Returns:
        Список ToolDefinition объектов
    """
    tools = [
        HTTPGetTool,
        HTTPPostTool,
        CheckURLStatusTool
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
