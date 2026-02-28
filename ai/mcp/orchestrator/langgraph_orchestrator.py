"""
LangGraph Orchestrator для маршрутизации запросов к AutoGen агентам
Использует trigger_keywords из agents_mapping.json для умной маршрутизации
"""

from langgraph.graph import StateGraph, END
from typing import TypedDict, Literal, Annotated, List, Dict, Any
import operator
import json
from pathlib import Path
from autogen_agents_generator import AutoGenAgentsGenerator

# Путь к маппингу агентов
AGENTS_MAPPING_PATH = Path(__file__).parent.parent / "agents_mapping.json"


class AgentState(TypedDict):
    """Состояние графа для маршрутизации между агентами"""
    query: str  # Запрос пользователя
    context: list[str]  # RAG-результаты из Qdrant
    agent_response: str  # Ответ выбранного агента
    selected_roles: Annotated[list[str], operator.add]  # История выбранных ролей
    conversation_history: list[dict]  # История диалога
    context_from_qdrant: list[str]  # RAG-контекст из Qdrant


class LangGraphOrchestrator:
    """
    Orchestrator на базе LangGraph для маршрутизации запросов к AutoGen агентам
    Использует trigger_keywords из agents_mapping.json для умной маршрутизации
    """

    def __init__(self):
        self.agents_config: Dict[str, Any] = {}
        self.autogen_generator: AutoGenAgentsGenerator = None
        self.workflow: StateGraph = None
        self.app = None

        # Загрузка маппинга агентов
        self._load_agents_mapping()

    def _load_agents_mapping(self) -> None:
        """Загрузка маппинга агентов из JSON файла"""
        with open(AGENTS_MAPPING_PATH, 'r', encoding='utf-8') as f:
            data = json.load(f)
            self.agents_config = data
        print(f"✅ Загружено {len(self.agents_config['agents'])} агентов для маршрутизации")

    def _build_trigger_keywords_index(self) -> Dict[str, List[str]]:
        """
        Создание индекса trigger_keywords для быстрой маршрутизации
        Возвращает словарь: {keyword: [agent_types]}
        """
        keyword_index = {}

        for agent_data in self.agents_config['agents']:
            subagent_type = agent_data['subagent_type']
            trigger_keywords = agent_data.get('trigger_keywords', [])

            for keyword in trigger_keywords:
                keyword_lower = keyword.lower()
                if keyword_lower not in keyword_index:
                    keyword_index[keyword_lower] = []
                if subagent_type not in keyword_index[keyword_lower]:
                    keyword_index[keyword_lower].append(subagent_type)

        return keyword_index

    def _route_by_keyword(self, state: AgentState) -> Literal[
        "client_developer",
        "server_developer",
        "designer",
        "cto",
        "project_analysis",
        "feature_analysis",
        "staff_engineer",
        "devops",
        "product_manager",
        "head_of_qa",
        "client_security_engineer",
        "server_security_engineer",
        "analytics_engineer",
        "end"
    ]:
        """
        Маршрутизация запроса к агенту на основе trigger_keywords
        Использует индекс из _build_trigger_keywords_index()
        """
        query = state["query"].lower()

        # Создаём индекс trigger_keywords (кэшируем для производительности)
        if not hasattr(self, '_keyword_index'):
            self._keyword_index = self._build_trigger_keywords_index()

        # Поиск совпадений в запросе
        matched_agents = []
        for keyword, agents in self._keyword_index.items():
            if keyword in query:
                matched_agents.extend(agents)

        # Приоритетная маршрутизация (если есть точное совпадение)
        priority_keywords = {
            "UI": ["client_developer", "designer"],
            "SwiftUI": ["client_developer", "designer"],
            "View": ["client_developer"],
            "ViewModel": ["client_developer"],
            "API": ["server_developer", "server_integration_engineer"],
            "LM Studio": ["server_developer", "server_integration_engineer"],
            "network": ["server_developer"],
            "SSE": ["server_developer"],
            "архитектура": ["cto", "staff_engineer"],
            "рефакторинг": ["staff_engineer", "cto"],
            "тестирование": ["head_of_qa", "client_qa_lead", "server_qa_lead"],
            "дизайн": ["designer", "designer_lead"],
            "сборка": ["devops", "devops_lead"],
            "анализ проекта": ["project_analysis", "cto"],
            "новая фича": ["feature_analysis", "product_manager"],
        }

        # Проверка на приоритетные ключевые слова
        for keyword, agents in priority_keywords.items():
            if keyword.lower() in query:
                return agents[0]  # Возвращаем первого агента из списка

        # Если есть совпадения в общем индексе - используем их
        if hasattr(self, '_keyword_index') and self._keyword_index:
            matched_agents = []
            for keyword, agents in self._keyword_index.items():
                if keyword.lower() in query:
                    matched_agents.extend(agents)

            # Возвращаем первого уникального агента
            unique_agents = list(dict.fromkeys(matched_agents))
            if unique_agents:
                return unique_agents[0]

        # Fallback: CTO для сложных/неоднозначных задач
        return "cto"

    def _call_autogen_agent(self, state: AgentState) -> Dict[str, Any]:
        """
        Вызов AutoGen агента (синхронная версия для LangGraph)
        В production использовать async version
        """
        selected_role = state["selected_roles"][-1]  # Берём последний выбранный агент

        if not self.autogen_generator:
            return {
                "agent_response": f"❌ AutoGen генератор не инициализирован. Вызовите .init_autogen()",
                "context": state["context"]
            }

        agent = self.autogen_generator.auto_gen_agents.get(selected_role)
        if not agent:
            return {
                "agent_response": f"❌ Агент '{selected_role}' не найден",
                "context": state["context"]
            }

        # Вызов агента
        response = agent.generate_reply(
            messages=[{"role": "user", "content": state["query"]}]
        )

        content = response.get("content", "No response")

        return {
            "agent_response": content,
            "context": state["context"] + [content],  # Добавляем в контекст для RAG
        }

    def _add_qdrant_context(self, state: AgentState) -> Dict[str, Any]:
        """
        Добавление контекста из Qdrant (RAG)
        В production - реальный запрос к векторной базе
        """
        # Здесь будет интеграция с Qdrant через MCP Memory Server
        # Для примера возвращаем пустой список
        return {
            "context_from_qdrant": []
        }

    def init_autogen(self) -> None:
        """Инициализация AutoGen агентов"""
        from autogen_agents_generator import AutoGenAgentsGenerator
        self.autogen_generator = AutoGenAgentsGenerator()
        components = self.autogen_generator.run()
        print("✅ AutoGen агенты инициализированы")

    def build_workflow(self) -> StateGraph:
        """
        Построение LangGraph workflow с маршрутизацией к AutoGen агентам
        """
        # Создаём граф состояний
        workflow = StateGraph(AgentState)

        # Добавляем узел для вызова AutoGen агента
        workflow.add_node("autogen_executor", self._call_autogen_agent)

        # Добавляем узел для добавления Qdrant контекста (RAG)
        workflow.add_node("rag_context", self._add_qdrant_context)

        # Маршрутизация по trigger keywords
        workflow.add_conditional_edges(
            "start",
            self._route_by_keyword,
            {
                "client_developer": "autogen_executor",
                "server_developer": "autogen_executor",
                "designer": "autogen_executor",
                "cto": "autogen_executor",
                "project_analysis": "autogen_executor",
                "feature_analysis": "autogen_executor",
                "staff_engineer": "autogen_executor",
                "devops": "autogen_executor",
                "product_manager": "autogen_executor",
                "head_of_qa": "autogen_executor",
                "client_security_engineer": "autogen_executor",
                "server_security_engineer": "autogen_executor",
                "analytics_engineer": "autogen_executor",
            }
        )

        # Добавляем edge от autogen_executor к END
        workflow.add_edge("autogen_executor", "end")

        return workflow

    def compile(self) -> None:
        """
        Компиляция workflow и создание приложения LangGraph
        """
        self.workflow = self.build_workflow()
        self.app = self.workflow.compile()
        print("✅ LangGraph workflow скомпилирован")

    def invoke(self, query: str) -> Dict[str, Any]:
        """
        Запуск workflow с запросом пользователя
        Возвращает результат выполнения графа
        """
        if not self.app:
            return {"error": "Workflow не инициализирован. Вызовите .compile()"}

        # Создаём начальное состояние
        initial_state: AgentState = {
            "query": query,
            "context": [],
            "agent_response": "",
            "selected_roles": [],
            "conversation_history": [],
            "context_from_qdrant": []
        }

        # Добавляем начальную роль (будет добавлена маршрутизатором)
        initial_state["selected_roles"] = ["start"]

        # Запуск workflow
        result = self.app.invoke(initial_state)

        return {
            "query": query,
            "agent_response": result.get("agent_response", "No response"),
            "selected_agent": result["selected_roles"][-1] if result["selected_roles"] else "unknown",
            "context": result.get("context", []),
        }


# Основной запуск для тестирования
if __name__ == "__main__":
    print("🚀 Запуск LangGraph Orchestrator...")

    orchestrator = LangGraphOrchestrator()

    # Инициализация AutoGen агентов
    orchestrator.init_autogen()

    # Компиляция workflow
    orchestrator.compile()

    # Примеры запросов
    test_queries = [
        "Создай SwiftUI View для экрана чата",
        "Как интегрировать LM Studio API?",
        "Нужен рефакторинг архитектуры проекта",
        "Какие тесты нужны для нового функционала?",
    ]

    print("\n📝 Тестирование маршрутизации:")
    for query in test_queries:
        result = orchestrator.invoke(query)
        print(f"\n❓ Запрос: {query}")
        print(f"→ Агент: {result['selected_agent']}")
        print(f"→ Ответ (первые 200 символов): {result['agent_response'][:200]}...")
