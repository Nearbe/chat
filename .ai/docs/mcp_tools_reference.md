# MCP Tools Reference (LM Studio)

Полная документация всех доступных инструментов для LM Studio Qwen3.5-35B-A3B-Q8_0 Bridge Agent.

---

## 🔹 MCP IDEA (IntelliJ IDEA Integration — доступ к ПРОЕКТУ)

Инструменты для работы с проектом внутри IntelliJ IDEA:

| Инструмент | Описание |
|------------|----------|
| `create_new_file` | Создание файлов ≤700 строк в один вызов |
| `replace_text_in_file` | Замена текста для больших файлов (разбивка на части) |
| `get_file_text_by_path(startLine, maxLinesCount)` | Чтение по частям 50-100 строк |
| `list_directory_tree(maxDepth)` | Дерево директорий с параметром глубины |
| `search_in_files_by_text(searchText, ...)` | Поиск текста в файлах проекта |
| `search_in_files_by_regex(regexPattern, ...)` | Поиск регулярки в файлах проекта |
| `find_files_by_name_keyword(nameKeyword, ...)` | Поиск файлов по ключевому слову в имени |
| `find_files_by_glob(globPattern, ...)` | Поиск файлов по glob паттерну |
| `get_file_problems(errorsOnly)` | Анализ ошибок/предупреждений в файле проекта |
| `get_symbol_info(line, column)` | Информация о символе (1-based line/column) |
| `rename_refactoring(oldName, newName)` | Переименование с обновлением ВСЕХ ссылок в проекте |
| `execute_terminal_command(timeout, projectPath)` | Выполнение терминальных команд в IDEA терминале |
| `open_file_in_editor(filePath, projectPath)` | Открытие файла в редакторе IDEA |
| `reformat_file(path, projectPath)` | Форматирование файла по правилам IDE |
| `get_project_modules(projectPath)` | Получение модулей проекта с их типами |
| `get_run_configurations(projectPath)` | Получение конфигураций запуска |
| `execute_run_configuration(configurationName, timeout, ...)` | Выполнение run configuration задач/тестов |
| `build_project(rebuild, filesToRebuild, timeout, projectPath)` | Сборка проекта |

---

## 🔹 MCP AI-FS (AI Filesystem — доступ к ФАЙЛОВОЙ СИСТЕМЕ)

Инструменты для управления собственной файловой системой окружения:

| Инструмент | Описание |
|------------|----------|
| `read_file(path)` | Чтение файла целиком (оптимально для файлов ≤700 строк) |
| `write_file(path, content)` | Запись файла в файловую систему окружения |
| `update_file(path, updates[])` | Частичное обновление файла в файловой системе |
| `create_directory(path, recursive?)` | Создание директории в файловой системе |
| `list_directory(path, detailed?, pattern?)` | Список файлов в директории файловой системы |
| `move_file(source, destination)` | Перемещение/переименование файла в ФС |
| `copy_files(sources[], destination)` | Копирование файлов в ФС |
| `delete_file(path)` | Удаление файла из ФС |
| `search_files(pattern, directory)` | Поиск по паттерну (glob) в ФС |
| `search_content(pattern, directory, filePattern?)` | Поиск текста в файлах ФС |
| `fuzzy_search(pattern, directory?, threshold?, limit?, extensions?)` | Fuzzy matching файлов в ФС |
| `semantic_search(query, directory?, fileTypes?, limit?, includeContent?)` | Семантический поиск по коду в ФС |
| `get_file_metadata(path)` | Метаданные файла (размер, дата и т.д.) в ФС |
| `change_permissions(path, permissions, recursive?)` | Права доступа к файлам/папкам в ФС |
| `scan_secrets(directory)` | Сканирование на секреты/API ключи/пароли в ФС |
| `encrypt_file(path, password, algorithm?, outputPath?)` | Шифрование AES (aes-256-gcm/aes-256-cbc) |
| `decrypt_file(path, password, outputPath?)` | Дешифровка зашифрованных файлов в ФС |
| `compress_files(files[], outputPath, format?, compressionLevel?)` | Архивация (zip/tar/tar.gz/tar.bz2) |
| `extract_archive(archivePath, outputPath, filter?, overwrite?)` | Распаковка архивов из ФС |
| `file_watcher(action, path, events?, recursive?, ignorePatterns?)` | Мониторинг изменений файлов в ФС (start/stop/status/events) |
| `transaction(operations[], rollbackOnError?)` | Атомарные операции (create/read/update/delete) в ФС |
| `get_deep_directory_tree(path, options?)` | Глубокое дерево директорий с exclusion patterns |

---

## 🔹 MCP GIT (Git Integration)

Инструменты для работы с git репозиторием:

| Инструмент | Описание |
|------------|----------|
| `git_add(files, path)` | Staging изменений |
| `git_commit(message, files, path)` | Коммит с сообщением |
| `git_status(path)` | Статус репозитория |
| `git_push(remote, branch, force, setUpstream, path)` | Пуш в remote |
| `git_diff(file1, file2, format, context)` | Сравнение файлов |
| `git_log(limit, path)` | История коммитов |
| `git_clone(url, directory?, branch?, depth?, bare?)` | Клонирование репозитория |
| `git_checkout(branch, create?, force?, path)` | Переключение веток/восстановление файлов |
| `git_branch(action, name?, newName?, all?, remote?, force?, path)` | Управление ветками (list/create/delete/rename) |

---

## 🔹 MCP EXTERNAL (Внешние сервисы и API)

Инструменты для работы с внешними сервисами:

| Инструмент | Описание |
|------------|----------|
| `sequential-thinking(thought, nextThoughtNeeded, thoughtNumber, totalThoughts, ...)` | Планирование сложных задач через цепочку мыслей (основной tool для декомпозиции!) |
| `resolve_library_id(query, libraryName)` | Разрешение package/product name в Context7-compatible library ID |
| `query_docs(libraryId, query)` | Запрос документации и кода из Context7 для библиотек/фреймворков |
| `fetch_html(url, headers?, max_length?, start_index?)` | Fetch HTML страницы (публичные API/docs) |
| `fetch_markdown(url, headers?, max_length?, start_index?)` | Fetch Markdown страницы |
| `fetch_txt(url, headers?, max_length?, start_index?)` | Fetch plain text (без HTML) |
| `fetch_json(url, headers?, max_length?, start_index?)` | Fetch JSON файла |
| `remote_ssh(host, user, command, privateKeyPath?, port?)` | SSH команды на удалённых серверах |
| `ssh_read_lines(host, user, filePath, startLine?, endLine?, maxLines?, ...)` | Чтение строк из remote файлов |
| `ssh_edit_block(host, user, filePath, oldText, newText, expectedReplacements?, ...)` | Редактирование блоков в remote файлах |
| `ssh_search_code(host, user, path, pattern, filePattern?, ignoreCase?, ...)` | Поиск кода на удалённых серверах |
| `ssh_write_chunk(host, user, filePath, content, mode?, privateKeyPath?, port?)` | Запись контента в remote файлы |
| `current_time(format?, timezone?)` | Текущее время |
| `add_time(duration, time?, format?, timezone?)` | Добавление/вычитание длительности от времени |
| `compare_time(time_a, time_b, time_a_timezone?, time_b_timezone?)` | Сравнение двух времён |
| `convert_timezone(time, input_timezone?, output_timezone?, format?)` | Конвертация часовых поясов |
| `relative_time(text, time?, format?, timezone?)` | Время на основе относительного выражения (now, today, yesterday, etc.) |

---

## 🔹 MCP CODE ANALYSIS (Анализ кода)

Инструменты для анализа кода:

| Инструмент | Описание |
|------------|----------|
| `analyze_code(path, options?)` | Анализ структуры TypeScript/JavaScript (summary/detailed/json) |
| `format_code(path, style?, config?, fix?)` | Форматирование кода (prettier/eslint по умолчанию) |
| `suggest_refactoring(path, type?)` | Рефакторинг (all/complexity/naming/structure/performance) |
| `modify_code(path, modifications[])` | AST трансформации кода (rename/addImport/removeImport/addFunction/updateFunction/addProperty) |
| `diff_files(file1, file2, format?, context?, ignoreWhitespace?)` | Сравнение файлов (unified/context/side-by-side/json) |

---

## 🔹 MCP PROJECT INTEGRATION (Интеграция с проектом)

Инструменты для интеграции с проектом:

| Инструмент | Описание |
|------------|----------|
| `get_project_dependencies(projectPath)` | Получение списка зависимостей проекта |
| `get_repositories(projectPath)` | Получение списка VCS roots в проекте |

---

## 📁 DOCUMENTATION STRUCTURE

- `.ai/system_prompt/assistent.md` — краткий системный промт с обзором категорий инструментов
- `.ai/docs/mcp_tools_reference.md` — полная документация всех MCP инструментов (этот файл)
- `.ai/docs/rules.md` — правила и best practices проекта
- Вся актуальная документация хранится в `.ai/` папке

---

## 🔄 QUICK REFERENCE

### Для работы с проектом:
```bash
# Чтение файла проекта
get_file_text_by_path(path, startLine, maxLinesCount)

# Поиск по проекту
search_in_files_by_text("pattern")
search_in_files_by_regex("regexPattern")
find_files_by_name_keyword("keyword")

# Изменение кода
create_new_file(path, content)
replace_text_in_file(oldText, newText)
rename_refactoring(oldName, newName)

# Запуск задач
execute_terminal_command("command")
build_project()
```

### Для работы с файловой системой:
```bash
# Чтение/запись файлов
read_file(path)
write_file(path, content)

# Поиск по ФС
search_content("pattern", directory)
fuzzy_search("pattern", limit=20)
semantic_search("query", fileTypes=["swift"])

# Безопасность
scan_secrets(directory)
encrypt_file(path, password)
```

### Для работы с git:
```bash
git_add(".")
git_commit("message")
git_status()
git_push()
```

### Для планирования задач:
```bash
sequential-thinking(
  thought="Анализ задачи...",
  nextThoughtNeeded=true,
  thoughtNumber=1,
  totalThoughts=5
)
```

---

*Документация обновлена: v6.5 | Qwen3.5-35B-A3B-Q8_0 (LM Studio)*
