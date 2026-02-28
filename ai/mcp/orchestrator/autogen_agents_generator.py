"""
Генератор AutoGen агентов из agents_mapping.json
Создаёт 30+ ConversableAgent на основе маппинга субагентов
"""

import json
from pathlib import Path
from autogen import ConversableAgent, GroupChat, GroupChatManager
from typing import Dict, List, Any
import asyncio

# Путь к маппингу агентов
AGENTS_MAPPING_PATH = Path(__file__).parent.parent / "agents_mapping.json"


class AutoGenAgentsGenerator:
    """Генератор AutoGen агентов из agents_mapping.json"""

    def __init__(self):
        self.agents_config: Dict[str, Any] = {}
        self.auto_gen_agents: Dict[str, ConversableAgent] = {}
        self.llm_config: Dict[str, Any] = {
            "config_list": [
                {
                    "model": "qwen3.5:35b",
                    "base_url": "http://localhost:1234",  # Ollama на M4 Max
                    "max_tokens": 8192,
                }
            ]
        }

    def load_agents_mapping(self) -> None:
        """Загрузка маппинга агентов из JSON файла"""
        with open(AGENTS_MAPPING_PATH, 'r', encoding='utf-8') as f:
            self.agents_config = json.load(f)
        print(f"✅ Загружено {len(self.agents_config['agents'])} агентов")

    def get_system_prompt_for_role(self, subagent_type: str) -> str:
        """
        Генерация системного промпта для роли агента
        На основе domains и trigger_keywords из маппинга
        """
        agent_data = next(
            (a for a in self.agents_config['agents'] if a['subagent_type'] == subagent_type),
            None
        )

        if not agent_data:
            return f"Вы - агент {subagent_type}. Ваша задача - помочь пользователю."

        domains = ", ".join(agent_data['domains'])
        trigger_keywords = ", ".join(agent_data['trigger_keywords'][:5])  # Первые 5 ключевых слов
        access_level = agent_data.get('access', 'full')
        department = agent_data.get('department', '')

        prompt = f"""
Вы - {subagent_type} в команде проекта Chat (iOS, SwiftUI, LM Studio integration).

ВАШИ ОБЯЗАННОСТИ:
- Экспертиза: {domains}
- Триггерные ключевые слова для активации: {trigger_keywords}
- Уровень доступа к workspace: {access_level}
"""

        if department:
            prompt += f"\nДепартамент: {department}"

        prompt += f"""

ВАШИ ОГРАНИЧЕНИЯ:
- Рабочая директория: {agent_data.get('workspace', 'N/A')}
- Не выходите за рамки своей экспертизы ({domains})
- Если задача не в вашей компетенции - перенаправьте к соответствующему агенту или CTO

ВАШИ ИНСТРУКЦИИ:
1. Анализируйте запрос пользователя на trigger keywords: {trigger_keywords}
2. Используйте контекст проекта Chat (iOS 18+, SwiftUI, SwiftData, LM Studio integration)
3. Следуйте ограничениям: SwiftLint 160 символов, Docstrings обязательны
4. При необходимости запрашивайте уточнения у пользователя или других агентов
5. Финальный ответ должен быть на русском языке с техническими деталями в коде

TERMINATE сигнал: Если задача выполнена и вы ждёте обратной связи - добавьте "TERMINATE" в конец ответа.
"""

        return prompt.strip()

    def create_agents(self) -> Dict[str, ConversableAgent]:
        """Создание всех AutoGen агентов на основе маппинга"""
        self.auto_gen_agents = {}

        for agent_data in self.agents_config['agents']:
            subagent_type = agent_data['subagent_type']
            system_prompt = self.get_system_prompt_for_role(subagent_type)

            # Создание ConversableAgent
            agent = ConversableAgent(
                name=subagent_type,
                llm_config=self.llm_config,
                system_message=system_prompt,
                is_termination_msg=lambda x: "TERMINATE" in str(x.get("content", "")),
                human_input_mode="NEVER",  # Автоматический режим
                max_consecutive_auto_reply=3,  # Ограничение на количество авто-ответов
            )

            self.auto_gen_agents[subagent_type] = agent
            print(f"✅ Создан агент: {subagent_type}")

        return self.auto_gen_agents

    def create_group_chat(self) -> tuple[GroupChat, GroupChatManager]:
        """
        Создание GroupChat для параллельного выполнения агентов
        speaker_selection_method="auto" для умной маршрутизации
        """
        agents_list = list(self.auto_gen_agents.values())

        group_chat = GroupChat(
            agents=agents_list,
            messages=[],
            max_round=12,  # Ограничение на количество раундов
            speaker_selection_method="auto",  # Умная маршрутизация по контексту
            allow_repeat_speaker=False,  # Избегать повторов одного агента
        )

        manager = GroupChatManager(
            groupchat=group_chat,
            llm_config=self.llm_config,
            name="orchestrator",
        )

        return group_chat, manager

    async def execute_agent_task(self, role: str, query: str) -> str:
        """
        Async-обёртка для вызова конкретного AutoGen агента
        Используется для интеграции с LangGraph
        """
        if role not in self.auto_gen_agents:
            return f"❌ Агент '{role}' не найден. Доступные: {list(self.auto_gen_agents.keys())}"

        agent = self.auto_gen_agents[role]

        # Async вызов generate_reply
        response = await asyncio.to_thread(
            agent.generate_reply,
            messages=[{"role": "user", "content": query}]
        )

        return response.get("content", "No response")

    def export_agents(self) -> Dict[str, Any]:
        """
        Экспорт конфигурации агентов для использования в других модулях
        Возвращает словарь с именами агентов и их настройками
        """
        return {
            "agents": list(self.auto_gen_agents.keys()),
            "count": len(self.auto_gen_agents),
            "llm_config": self.llm_config,
            "fallback": "cto",  # CTO как fallback для неизвестных задач
        }

    def run(self):
        """
        Полный цикл создания агентов и GroupChat
        Возвращает все компоненты для интеграции с LangGraph
        """
        print("🚀 Запуск генератора AutoGen агентов...")
        self.load_agents_mapping()
        agents = self.create_agents()
        group_chat, manager = self.create_group_chat()

        print(f"\n✅ Готово! Создано {len(agents)} агентов")
        print("📦 Экспорт компонентов:")
        print(f"  - agents: {list(self.auto_gen_agents.keys())}")
        print(f"  - group_chat: {group_chat}")
        print(f"  - manager: {manager}")

        return {
            "agents": self.auto_gen_agents,
            "group_chat": group_chat,
            "manager": manager,
            "export": self.export_agents(),
        }


# Основной запуск
if __name__ == "__main__":
    generator = AutoGenAgentsGenerator()
    components = generator.run()

    # Пример использования:
    print("\n📝 Пример вызова агента:")


    async def example():
        response = await generator.execute_agent_task(
            "client_developer",
            "Создай SwiftUI View для экрана чата"
        )
        print(response)

    # asyncio.run(example())  # Раскомментировать для тестирования
