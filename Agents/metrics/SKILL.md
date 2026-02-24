---
name: metrics
description: Этот навык следует использовать, когда пользователь просит "собери метрики", "отчёт по метрикам", "проверь ресурсы", "свободное место". Агент отвечает за сбор и мониторинг метрик проекта.
version: 0.3.0
---

# Metrics Agent

## Обзор

Агент для сбора и мониторинга метрик проекта Chat. Собирает данные о ресурсах машины, времени сборки, тестах, размере
проекта и других технических показателях. Использует SQLite для надёжного хранения данных.

## Структура

```
Agents/metrics/
├── Package.swift                # Swift Package Definition
├── Models/
│   └── MetricsRecord.swift     # Модель данных
├── Services/
│   ├── DatabaseManager.swift   # SQLite менеджер
│   ├── ResourceMonitor.swift   # CPU/RAM мониторинг
│   └── MetricsCollector.swift  # Основной сервис
├── CLI/
│   └── main.swift              # Command-line интерфейс
└── workspace/
    ├── metrics.db              # SQLite база данных
    ├── reports/                # Еженедельные отчёты
    └── history/                # История метрик
```

## Активация
Используй этот навык когда пользователь:
- Просит "собери метрики проекта"
- Запрашивает "сколько ресурсов использует проект"
- Говорит "отчёт по метрикам"
- Просит "проверь свободное место"
- Интересуется "время сборки"
- Хочет "историю метрик"
- Просит "статистику по операциям"

## Запуск

```bash
cd Agents/metrics
swift run metrics-collector <command>
```

## Команды

### current

Показать текущие ресурсы системы:

```bash
swift run metrics-collector current
```

### run <operation> <command>

Выполнить команду и собрать метрики:

```bash
# Пример: сборка xcodebuild с метриками
swift run metrics-collector run xcodebuild "xcodebuild -scheme Chat build"

# Пример: тесты с метриками
swift run metrics-collector run test "xcodebuild test -scheme Chat"
```

### stats [operation]

Показать статистику:

```bash
# Статистика по конкретной операции
swift run metrics-collector stats xcodebuild

# Все операции
swift run metrics-collector stats
```

### list [limit]

Список последних записей:

```bash
swift run metrics-collector list 20
```

## База данных

### Расположение

```
/Users/nearbe/repositories/Chat/Agents/metrics/workspace/metrics.db
```

### Просмотр в JetBrains IDE

```
jdbc:sqlite:/Users/nearbe/repositories/Chat/Agents/metrics/workspace/metrics.db
```

Или просто открыть файл `metrics.db` в DataGrip/Rider с плагином SQLite.

### Таблица: metrics

| Колонка           | Тип         | Описание                           |
|-------------------|-------------|------------------------------------|
| id                | TEXT (UUID) | Уникальный ID                      |
| operation         | TEXT        | Название (xcodebuild, test, check) |
| timestamp         | REAL (Date) | Время начала                       |
| duration_seconds  | REAL        | Продолжительность                  |
| cpu_before        | REAL        | CPU до операции (%)                |
| cpu_during_avg    | REAL        | CPU среднее (%)                    |
| cpu_peak          | REAL        | CPU пиковое (%)                    |
| ram_before_mb     | INT         | RAM до (MB)                        |
| ram_during_avg_mb | INT         | RAM среднее (MB)                   |
| ram_peak_mb       | INT         | RAM пиковое (MB)                   |
| exit_code         | INT         | Код завершения                     |
| warnings_count    | INT         | Warnings                           |
| errors_count      | INT         | Errors                             |
| output_size_kb    | INT         | Размер вывода (KB)                 |
| xcode_version     | TEXT        | Версия Xcode                       |
| swift_version     | TEXT        | Версия Swift                       |
| scheme_name       | TEXT        | Название схемы                     |

## Возможности

1. **Мониторинг CPU/RAM в реальном времени** - 100ms интервал
2. **Автоматический подсчёт warnings/errors** - из вывода команды
3. **Сохранение версий Xcode/Swift** - для анализа изменений
4. **Статистика по операциям** - среднее время, CPU, RAM
5. **SQLite хранилище** - надёжное и быстрое

## Зависимости

- SQLite.swift (0.15.3)
