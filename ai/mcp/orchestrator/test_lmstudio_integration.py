"""
LM Studio Integration Test
Тестирование работы Tool Registry с LM Studio API
"""

import json
from typing import Dict, Any


def test_tool_registry_with_lmstudio():
    """
    Тест интеграции Tool Registry с LM Studio
    
    Этот скрипт:
    1. Создает ToolRegistry и регистрирует инструменты
    2. Получает function definitions
    3. Отправляет запрос к LM Studio
    4. Обрабатывает tool calls
    """
    
    from tools import ToolRegistry, get_registry
    from tools.tools.file_system import ListDirectoryTool, ReadFileTool
    from tools.tools.search import SearchInFilesTool, GitLogTool
    
    # Создаем реестр
    registry = get_registry()
    
    print("📦 Зарегистрированные инструменты:")
    print("=" * 50)
    
    # Регистрируем инструменты через декоратор
    @registry.register(
        name="list_directory",
        description=ListDirectoryTool.description,
        parameters=ListDirectoryTool.parameters
    )
    def list_dir(path: str):
        return ListDirectoryTool.execute(path)
    
    @registry.register(
        name="read_file",
        description=ReadFileTool.description,
        parameters=ReadFileTool.parameters
    )
    def read_file_func(path: str, max_lines: int = 1000):
        return ReadFileTool.execute(path, max_lines)
    
    @registry.register(
        name="search_in_files",
        description=SearchInFilesTool.description,
        parameters=SearchInFilesTool.parameters
    )
    def search_files(pattern: str, file_pattern: str = "*"):
        return SearchInFilesTool.execute(pattern, file_pattern)
    
    @registry.register(
        name="git_log",
        description=GitLogTool.description,
        parameters=GitLogTool.parameters
    )
    def get_git(limit: int = 10):
        return GitLogTool.execute(limit)
    
    # Выводим зарегистрированные инструменты
    for tool_name in registry.tools:
        print(f"✅ {tool_name}")
    
    print("\n" + "=" * 50)
    print("📋 Function Definitions для LM Studio:")
    print("=" * 50)
    
    # Получаем определения инструментов
    definitions = [registry.get_function_definition(name) for name in registry.tools]
    
    for definition in definitions:
        if definition:
            func_def = definition.function
            print(f"\n{name}:")
            print(f"  Name: {func_def['name']}")
            print(f"  Description: {func_def['description'][:100]}...")
            print(f"  Parameters: {json.dumps(func_def['parameters'], indent=2)}")
    
    return registry


def simulate_lmstudio_tool_call():
    """
    Симуляция вызова инструмента как от LM Studio
    
    Пример того, как будет выглядеть вызов после получения tool call от модели
    """
    
    from tools import get_registry
    
    registry = get_registry()
    
    # Симулированный tool call от LM Studio
    simulated_tool_call = {
        "name": "list_directory",
        "arguments": {
            "path": "/Users/nearbe/repositories/Chat"
        }
    }
    
    print("\n🔄 Симуляция вызова инструмента:")
    print(f"   Инструмент: {simulated_tool_call['name']}")
    print(f"   Параметры: {json.dumps(simulated_tool_call['arguments'], indent=4)}")
    
    # Выполняем вызов
    result = registry.call(
        tool_name=simulated_tool_call["name"],
        **simulated_tool_call["arguments"]
    )
    
    print("\n✅ Результат:")
    if result.success:
        print(f"   Успешно выполнен за {result.execution_time_ms:.2f}ms")
        print(f"   Тип результата: {type(result.result).__name__}")
        if isinstance(result.result, list):
            print(f"   Количество элементов: {len(result.result)}")
    else:
        print(f"   ❌ Ошибка: {result.error}")


def test_with_real_lmstudio():
    """
    Тест с реальным LM Studio сервером
    
    Требует запущенный LM Studio на http://localhost:1234
    """
    
    try:
        from openai import OpenAI
        
        # Подключаемся к LM Studio
        client = OpenAI(
            base_url="http://localhost:1234/v1",
            api_key="lm-studio"
        )
        
        # Получаем все функции из реестра
        registry = get_registry()
        functions = [registry.get_function_definition(name) for name in registry.tools]
        
        print("\n🚀 Тест с реальным LM Studio:")
        print("=" * 50)
        
        # Отправляем запрос к модели
        response = client.chat.completions.create(
            model="qwen3.5-35b",  # Или другое имя вашей модели
            messages=[{
                "role": "user",
                "content": "Какими инструментами я могу пользоваться в этом проекте?"
            }],
            tools=functions,
            temperature=0.7
        )
        
        print("\n📊 Ответ от LM Studio:")
        print(f"   Content: {response.choices[0].message.content}")
        
        # Проверяем tool calls
        if response.choices[0].message.tool_calls:
            print("\n🔧 Tool Calls:")
            for tc in response.choices[0].message.tool_calls:
                print(f"\n   Инструмент: {tc.function.name}")
                print(f"   Аргументы: {tc.function.arguments}")
                
                # Выполняем вызов
                result = registry.call(
                    tool_name=tc.function.name,
                    **json.loads(tc.function.arguments)
                )
                
                if result.success:
                    print(f"   ✅ Результат: {result.result}")
                else:
                    print(f"   ❌ Ошибка: {result.error}")


    except Exception as e:
        print(f"\n❌ Ошибка при подключении к LM Studio:")
        print(f"   {e}")
        print("\n💡 Убедитесь что LM Studio запущен на http://localhost:1234")


if __name__ == "__main__":
    print("=" * 60)
    print("🧪 Тестирование Tool Registry с LM Studio API")
    print("=" * 60)
    
    # Базовый тест (без реального LM Studio)
    registry = test_tool_registry_with_lmstudio()
    simulate_lmstudio_tool_call()
    
    # Тест с реальным LM Studio (опционально)
    try:
        test_with_real_lmstudio()
    except Exception as e:
        print(f"\n⚠️  Пропущен тест с реальным LM Studio: {e}")
    
    print("\n" + "=" * 60)
    print("✅ Тестирование завершено")
    print("=" * 60)
