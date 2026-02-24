# Структура команды агентов

## Иерархия

```
@nearbe (Владелец)
│
├── Owner Product Consultant
│   → Согласовывает решения с @nearbe
│
├── Product Manager
│   → Планирует задачи
│
├── CTO
│   → Техническое руководство
│
├── Staff Engineer
│   → Технические решения среднего уровня, code review, документация
│
├── Client Lead
│   └── Client Developer
│
├── Server Lead
│   └── Server Developer
│
├── Designer Lead
│   └── Designer
│
├── DevOps Lead
│   └── DevOps
│
├── Head of QA
│   ├── Client QA Lead
│   ├── Server QA Lead
│   ├── Designer QA Lead
│   └── DevOps QA Lead
│
├── Documents Lead
│
└── HR
    → Создание новых агентов
```

## Права доступа агентов

| Агент                    | Доступ к проекту | Коммиты | Рабочая директория                         |
|--------------------------|------------------|---------|--------------------------------------------|
| Owner Product Consultant | Чтение           | Нет     | Agents/owner-product-consultant/workspace/ |
| Product Manager          | Чтение           | Нет     | Agents/product-manager/workspace/          |
| CTO                      | Полный           | Да      | Agents/cto/workspace/                      |
| Staff Engineer           | Полный           | Да      | Agents/staff-engineer/workspace/           |
| Client Lead              | Полный           | Да      | Agents/client-lead/workspace/              |
| Server Lead              | Полный           | Да      | Agents/server-lead/workspace/              |
| Designer Lead            | Полный           | Да      | Agents/designer-lead/workspace/            |
| DevOps Lead              | Полный           | Да      | Agents/devops-lead/workspace/              |
| Client Developer         | Полный           | Да*     | Agents/client-developer/workspace/         |
| Server Developer         | Полный           | Да*     | Agents/server-developer/workspace/         |
| Designer                 | Чтение           | Да*     | Agents/designer/workspace/                 |
| DevOps                   | Чтение           | Да*     | Agents/devops/workspace/                   |
| Head of QA               | Чтение           | Да      | Agents/head-of-qa/workspace/               |
| Client QA Lead           | Полный           | Да      | Agents/client-qa-lead/workspace/           |
| Server QA Lead           | Полный           | Да      | Agents/server-qa-lead/workspace/           |
| Designer QA Lead         | Полный           | Да      | Agents/designer-qa-lead/workspace/         |
| DevOps QA Lead           | Полный           | Да      | Agents/devops-qa-lead/workspace/           |
| Documents Lead           | Полный           | Да      | Agents/documents-lead/workspace/           |
| HR                       | Чтение           | Да      | Agents/hr/workspace/                       |

*С разрешения лида

## Поток работы

1. **@nearbe** ставит задачу
2. **Owner Product Consultant** предлагает решение → согласует с @nearbe
3. **Product Manager** оценивает объём работ
4. **CTO** координирует реализацию
5. **Lead** (Client/Server/Designer/DevOps) ставит задачу разработчику
6. **Developer** реализует
7. **QA Lead** тестирует
8. **DevOps Lead** деплоит

## Создание нового агента

Используйте HR агента:

```
Запусти HR агента и попроси "создать нового агента для X"
```
