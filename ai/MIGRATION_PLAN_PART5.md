# 📋 Стратегия декомпозиции документации

Пользователь прав — файл `QWEN.md` (~38KB) стал слишком большим. Предлагаю разделить его на **логические модули** с
сохранением XML-структуры и кросс-ссылками.

---

## 🎯 ПРЕДЛОЖЕННАЯ СТРУКТУРА РАЗБИЕНИЯ

### Вариант 1: По доменам (рекомендуемый)

```
📁 docs/
├── 📄 QWEN.md                          ← Главный файл-контейнер (~2KB)
│   └── Содержит только metadata + ссылки на модули
│
├── 📁 modules/
│   ├── 📄 01_project_overview.xml       ← Обзор проекта, цели, стек технологий
│   ├── 📄 02_architecture.xml           ← Архитектура (MVVM, SwiftData)
│   ├── 📄 03_navigation.xml             ← Навигация и экраны приложения
│   ├── 📄 04_data_models.xml            ← Модели данных (SwiftData)
│   ├── 📄 05_api_integration.xml        ← API интеграции (LM Studio, Ollama)
│   ├── 📄 06_ui_components.xml          ← UI компоненты и стили
│   ├── 📄 07_state_management.xml       ← Управление состоянием (ObservableObject)
│   ├── 📄 08_authentication.xml         ← Аутентификация и безопасность
│   ├── 📄 09_localization.xml           ← Локализация (i18n)
│   ├── 📄 10_push_notifications.xml     ← Push уведомления (APNs)
│   ├── 📄 11_deep_linking.xml           ← Deep linking и universal links
│   ├── 📄 12_cloud_sync.xml             ← iCloud CloudKit синхронизация
│   └── 📄 99_references.xml             ← Ссылки на внешние ресурсы
```

---

## 🔧 РЕАЛИЗАЦИЯ: Главный файл QWEN.md (упрощённый)

Вот как будет выглядеть **главный контейнер** (~2KB вместо ~38KB):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<document>
    <metadata>
        <title>Проект Chat — iOS приложение</title>
        <version>2.0</version>
        <last_updated>2025-01-15</last_updated>
        <author>Team Nearbe</author>

        <!-- Ссылки на модули -->
        <modules>
            <module id="overview" path="../modules/01_project_overview.xml" />
            <module id="architecture" path="../modules/02_architecture.xml" />
            <module id="navigation" path="../modules/03_navigation.xml" />
            <module id="data_models" path="../modules/04_data_models.xml" />
            <module id="api_integration" path="../modules/05_api_integration.xml" />
            <module id="ui_components" path="../modules/06_ui_components.xml" />
            <module id="state_management" path="../modules/07_state_management.xml" />
            <module id="authentication" path="../modules/08_authentication.xml" />
            <module id="localization" path="../modules/09_localization.xml" />
            <module id="push_notifications" path="../modules/10_push_notifications.xml" />
            <module id="deep_linking" path="../modules/11_deep_linking.xml" />
            <module id="cloud_sync" path="../modules/12_cloud_sync.xml" />
        </modules>
    </metadata>

    <!-- Краткое резюме для быстрого доступа -->
    <summary>
        iOS приложение Chat с интеграцией LM Studio / Ollama / OpenAI API.
        Архитектура: SwiftUI + MVVM + SwiftData.

        Основные фичи:
        - Чат с AI (LM Studio, Ollama, OpenAI)
        - SSE streaming для ответов
        - История чатов с SwiftData
        - Push уведомления
        - iCloud синхронизация

        Технологии: SwiftUI, MVVM, SwiftData, URLSession, APNs.
    </summary>

    <!-- Ссылки на вспомогательные файлы -->
    <references>
        <file name="GUIDELINES.md" path="../docs/GUIDELINES.xml" />
        <file name="AGENTS.md" path="../docs/AGENTS.xml" />
        <file name="agents_mapping.yaml" path="../config/agents_mapping.yaml" />
    </references>

</document>
```

---

## 📁 ПРИМЕР МОДУЛЯ (01_project_overview.xml)

Вот как будет выглядеть **один модуль** (~2-3KB):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<module id="project_overview">
    <metadata>
        <title>Обзор проекта Chat</title>
        <version>1.0</version>
        <last_updated>2025-01-15</last_updated>
        <author>Team Nearbe</author>

        <!-- Ссылки на связанные модули -->
        <related_modules>
            <module id="architecture" path="../modules/02_architecture.xml" />
            <module id="data_models" path="../modules/04_data_models.xml" />
        </related_modules>
    </metadata>

    <!-- Основной контент модуля -->
    <content>

        <section name="project_description">
            <heading>Описание проекта</heading>

            <text>
                iOS приложение Chat — это клиент для работы с AI-моделями через
                LM Studio, Ollama и OpenAI API. Приложение позволяет пользователям:

                - Общаться с AI-моделями в реальном времени (SSE streaming)
                - Сохранять историю чатов локально (SwiftData)
                - Переключаться между разными провайдерами AI (LM Studio, Ollama, OpenAI)
                - Получать push уведомления о новых сообщениях

                Приложение разработано с использованием современных технологий:
                SwiftUI для UI, MVVM для архитектуры, SwiftData для хранения данных.
            </text>
        </section>

        <section name="key_features">
            <heading>Ключевые фичи</heading>

            <list type="features">
                <feature id="1">
                    <title>SSE Streaming</title>
                    <description>Реальное время отображение ответов AI-модели через Server-Sent Events.</description>
                </feature>

                <feature id="2">
                    <title>История чатов</title>
                    <description>Сохранение всех сообщений в локальной базе данных (SwiftData).</description>
                </feature>

                <feature id="3">
                    <title>Мульти-провайдер</title>
                    <description>Поддержка LM Studio, Ollama и OpenAI API с возможностью переключения.</description>
                </feature>

                <feature id="4">
                    <title>Push уведомления</title>
                    <description>APNs интеграция для уведомлений о новых сообщениях.</description>
                </feature>
            </list>
        </section>

        <section name="technology_stack">
            <heading>Стек технологий</heading>

            <grid columns="2">
                <item category="frontend">
                    <name>SwiftUI</name>
                    <version>18.0+</version>
                    <description>Декларативный UI фреймворк Apple.</description>
                </item>

                <item category="architecture">
                    <name>MVVM</name>
                    <version>N/A</version>
                    <description>Model-View-ViewModel паттерн архитектуры.</description>
                </item>

                <item category="data_storage">
                    <name>SwiftData</name>
                    <version>iOS 17+</version>
                    <description>Новая ORM от Apple для работы с данными.</description>
                </item>

                <item category="networking">
                    <name>URLSession</name>
                    <version>N/A</version>
                    <description>Нативный HTTP клиент iOS для API запросов.</description>
                </item>

                <item category="streaming">
                    <name>SSE (Server-Sent Events)</name>
                    <version>N/A</version>
                    <description>Потоковая передача данных от сервера к клиенту.</description>
                </item>
            </grid>
        </section>

        <section name="project_goals">
            <heading>Цели проекта</heading>

            <list type="objectives">
                <objective priority="high">
                    <title>UX First</title>
                    <description>Интуитивно понятный интерфейс для общения с AI.</description>
                </objective>

                <objective priority="medium">
                    <title>Performance</title>
                    <description>Быстрая загрузка чатов и минимальная задержка ответов.</description>
                </objective>

                <objective priority="high">
                    <title>Data Privacy</title>
                    <description>Все данные хранятся локально, без отправки на внешние серверы (кроме API
                        провайдеров).
                    </description>
                </objective>
            </list>
        </section>

    </content>

    <!-- Ссылки на связанные модули -->
    <references>
        <module id="architecture" path="../modules/02_architecture.xml" />
        <module id="data_models" path="../modules/04_data_models.xml" />
        <file name="GUIDELINES.md" path="../docs/GUIDELINES.xml" />
    </references>

</module>
```

---

## 📊 СРАВНЕНИЕ: ОДИН БОЛЬШОЙ ФАЙЛ vs РАЗБИТЫЕ МОДУЛИ

| Параметр                  | Один файл (QWEN.md) | Разбитые модули               |
|---------------------------|---------------------|-------------------------------|
| **Размер файла**          | ~38KB               | 2-4KB каждый                  |
| **Количество файлов**     | 1                   | 15-20 модулей                 |
| **Легкость навигации**    | ❌ Сложно (Ctrl+F)   | ✅ Быстро (открыл нужный файл) |
| **Редактирование**        | ⚠️ Риск конфликтов  | ✅ Параллельная работа         |
| **Размер одного файла**   | ~38KB               | 2-4KB                         |
| **Логическое разделение** | ❌ Смешано           | ✅ По доменам                  |

---

## 🎯 РЕКОМЕНДАЦИИ ПО ДЕКОМПОЗИЦИИ

### Этап 1: Создать структуру модулей

```bash
mkdir -p docs/modules
cd docs/modules

# Создать базовые модули (пример)
touch 01_project_overview.xml
touch 02_architecture.xml
touch 03_navigation.xml
touch 04_data_models.xml
touch 05_api_integration.xml
```

### Этап 2: Перенести контент из QWEN.md

Каждый раздел `QWEN.md` → отдельный XML-файл в `docs/modules/`.

### Этап 3: Обновить главный файл

В `QWEN.md` оставить только metadata + ссылки на модули.

---

## ✅ ВЫВОДЫ

**Да, мы можем разделить документацию!** Это даст:

1. **Легкость поддержки** — каждый модуль ~2-4KB вместо 38KB
2. **Параллельную работу** — разные агенты могут редактировать разные модули
3. **Быструю навигацию** — открыть нужный файл, а не искать в огромном файле
4. **Меньше конфликтов** — каждый модуль независим

---

## 🚀 СЛЕДУЮЩИЕ ШАГИ

Хотите:

1. ✅ **Создать структуру модулей** (я могу написать скрипт для генерации)
2. ✅ **Перенести контент из QWEN.md** в модули по частям
3. ✅ **Обновить главный файл** с ссылками на модули

Какой вариант выбираете?
