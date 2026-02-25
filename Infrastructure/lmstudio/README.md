# LM Studio Infrastructure

Запуск LM Studio в headless режиме для интеграции с iOS приложением Chat.

## Быстрый старт

### Docker Compose

```bash
cd Infrastructure/lmstudio
docker-compose up -d
```

### Проверка статуса

```bash
# Список запущенных контейнеров
docker-compose ps

# Логи
docker-compose logs -f

# Health check
curl http://localhost:1234/api/v1/models
```

### Остановка

```bash
docker-compose down
```

## Переменные окружения

| Переменная     | По умолчанию | Описание                |
|----------------|--------------|-------------------------|
| `LM_API_HOST`  | `0.0.0.0`    | Адрес для绑定             |
| `LM_API_PORT`  | `1234`       | Порт сервера            |
| `LM_API_TOKEN` | —            | API токен (опционально) |

## API Endpoints

| Метод | Эндпоинт              | Описание            |
|-------|-----------------------|---------------------|
| GET   | `/api/v1/models`      | Список моделей      |
| POST  | `/api/v1/models/load` | Загрузить модель    |
| POST  | `/api/v1/chat`        | Чат-комплишен (SSE) |

Полная документация: [Docs/LMStudio/developer/rest/](../Docs/LMStudio/developer/rest/index.md)

## Требования

- Docker 20.10+
- Docker Compose 2.0+
- 8GB RAM минимум (для LLM моделей)
