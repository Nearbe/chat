# Документация LM Studio

Этот раздел содержит локальную копию документации LM Studio, скачанную из официального репозитория.

## Структура документации

### [Разработчикам (Developer)](developer/index.md)
Обзор инструментов для разработчиков и возможностей интеграции.
- [API Changelog](developer/api-changelog.md) — история изменений API.

#### [REST API](developer/rest/index.md)
Прямое взаимодействие с сервером LM Studio через REST.
- [Quickstart](developer/rest/quickstart.md) — быстрый старт.
- [Endpoints](developer/rest/endpoints.md) — список доступных эндпоинтов.
- [Chat](developer/rest/chat.md) — создание чат-сессий.
- [Streaming Events](developer/rest/streaming-events.md) — работа с потоковыми ответами.
- [Model Lifecycle](developer/rest/index.md): [Load](developer/rest/load.md), [Unload](developer/rest/unload.md), [List](developer/rest/list.md).
- [Downloads](developer/rest/index.md): [Download](developer/rest/download.md), [Status](developer/rest/download-status.md).

#### [OpenAI Compatibility](developer/openai-compat/index.md)
Использование LM Studio как замены OpenAI API.
- [Chat Completions](developer/openai-compat/chat-completions.md) — совместимость с OpenAI Chat API.
- [Models](developer/openai-compat/models.md) — получение списка моделей.
- [Tools / Function Calling](developer/openai-compat/tools.md) — использование инструментов и функций.
- [Structured Output](developer/openai-compat/structured-output.md) — генерация структурированных данных (JSON).

### [LM Studio CLI](cli/index.md)
Использование командной строки `lms` для управления моделями и сервером.

### [Приложение (App)](app/index.md)
Общая информация о графическом интерфейсе LM Studio.

## Обновление документации

Для обновления документации используйте скрипт `download_docs.sh` в корне проекта:
```bash
./download_docs.sh
```

---
*Документация актуальна на февраль 2026 года.*
