#!/bin/bash
# Скрипт загрузки данных проекта Chat в MCP Memory Server

WINDOWS_HOST="192.168.1.107"
SERVER_URL="http://$WINDOWS_HOST:3000"

echo "=== Загрузка данных проекта Chat в MCP Memory ==="
echo "Server: $SERVER_URL"
echo ""

# Данные агентов и графов знаний для проекта Chat
cat > /tmp/chat_project_data.json << 'EOF'
{
  "nodes": [
    {
      "id": "agent_cto",
      "type": "agent",
      "name": "CTO / Architecture Lead",
      "content": {
        "role": "Координация команды агентов, архитектура проекта",
        "trigger_keywords": ["архитектура", "технологии", "координация"],
        "files": ["/AGENTS.md", "/QWEN.md", "/IMPROVEMENT_PLAN.md"]
      },
      "metadata": {"priority": 1, "team": "Core"}
    },
    {
      "id": "agent_client_developer",
      "type": "agent",
      "name": "Client Developer Lead",
      "content": {
        "role": "UI/SwiftUI разработка iOS приложения",
        "trigger_keywords": ["UI", "SwiftUI", "экран", "компонент"],
        "files": ["/Features/Chat/Views/ChatView.swift", "/App/ChatApp.swift"]
      },
      "metadata": {"priority": 1, "team": "Client"}
    },
    {
      "id": "agent_server_developer",
      "type": "agent",
      "name": "Server Developer Lead",
      "content": {
        "role": "API/LM Studio интеграция, сеть",
        "trigger_keywords": ["API", "сеть", "LM Studio", "SSE"],
        "files": ["/Services/Network/NetworkService.swift"]
      },
      "metadata": {"priority": 1, "team": "Server"}
    },
    {
      "id": "agent_devops_lead",
      "type": "agent",
      "name": "DevOps Lead",
      "content": {
        "role": "CI/CD, сборка, деплой на iPhone",
        "trigger_keywords": ["CI/CD", "сборка", "деплой", "xcodebuild"],
        "files": ["/Tools/Scripts/Sources/Commands/Ship.swift"]
      },
      "metadata": {"priority": 1, "team": "DevOps"}
    },
    {
      "id": "agent_client_qa_lead",
      "type": "agent",
      "name": "Client QA Lead",
      "content": {
        "role": "Тестирование UI, XCTest, SnapshotTesting",
        "trigger_keywords": ["тестирование", "XCTest", "SnapshotTesting"],
        "files": ["/Tests/ChatUITests"]
      },
      "metadata": {"priority": 1, "team": "QA"}
    },
    {
      "id": "agent_client_security_engineer",
      "type": "agent",
      "name": "Client Security Engineer",
      "content": {
        "role": "Безопасность, keychain, токены",
        "trigger_keywords": ["безопасность", "keychain", "токен"],
        "files": ["/Services/Security/KeychainService.swift"]
      },
      "metadata": {"priority": 1, "team": "Security"}
    },
    {
      "id": "agent_client_performance_engineer",
      "type": "agent",
      "name": "Client Performance Engineer",
      "content": {
        "role": "Performance, memory leak, profiling",
        "trigger_keywords": ["performance", "memory leak", "profiling"],
        "files": ["/Services/Monitoring/PerformanceMonitor.swift"]
      },
      "metadata": {"priority": 1, "team": "Performance"}
    }
  ],
  "edges": [
    {
      "id": "edge_cto_to_client",
      "source_id": "agent_cto",
      "target_id": "agent_client_developer",
      "relation_type": "manages",
      "weight": 1.0,
      "metadata": {"direction": "downstream"}
    },
    {
      "id": "edge_cto_to_server",
      "source_id": "agent_cto",
      "target_id": "agent_server_developer",
      "relation_type": "manages",
      "weight": 1.0,
      "metadata": {"direction": "downstream"}
    },
    {
      "id": "edge_client_to_devops",
      "source_id": "agent_client_developer",
      "target_id": "agent_devops_lead",
      "relation_type": "collaborates_with",
      "weight": 0.8,
      "metadata": {"direction": "bidirectional"}
    },
    {
      "id": "edge_server_to_qa",
      "source_id": "agent_server_developer",
      "target_id": "agent_client_qa_lead",
      "relation_type": "collaborates_with",
      "weight": 0.7,
      "metadata": {"direction": "bidirectional"}
    }
  ]
}
EOF

# Загрузка узлов графа знаний
echo "[1/3] Загрузка узлов агентов..."
curl -X POST "$SERVER_URL/nodes" \
  -H "Content-Type: application/json" \
  --data @/tmp/chat_project_data.json | jq '.success' && echo "✓ Узлы загружены" || echo "✗ Ошибка загрузки узлов"

# Загрузка связей
echo "[2/3] Загрузка связей графа..."
curl -X POST "$SERVER_URL/import" \
  -H "Content-Type: application/json" \
  --data @/tmp/chat_project_data.json | jq '.success' && echo "✓ Связи загружены" || echo "✗ Ошибка загрузки связей"

# Проверка статистики
echo "[3/3] Получение статистики графа..."
curl -s "$SERVER_URL/stats" | jq .

echo ""
echo "=== Данные проекта Chat загружены! ==="
echo "Проверь доступность:" 
echo "  curl http://192.168.1.107:3000/health"
echo "  curl http://192.168.1.107:3000/stats"
