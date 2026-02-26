# ============================================================================
#  AUTOMATED AI-AGENTS SETUP FOR WINDOWS
#  Запуск от имени администратора обязателен!
#  Флоу: Клонировал репозиторий → запустил setup.ps1 → всё установилось само
# ============================================================================

<#
.SYNOPSIS
    Полностью автоматическая настройка окружения AI-агентов на Windows
.DESCRIPTION
    Устанавливает Node.js, Ollama и все необходимые компоненты без ручного вмешательства.
    Работает в связке с Core моделью Qwen3.5-35B (Mac) через Continue.dev
.PARAMETER SkipInstallModels
    Пропустить загрузку моделей Ollama (если уже установлены)
.EXAMPLE
    .\windows\setup.ps1
#>

[CmdletBinding()]
param(
    [switch]$SkipInstallModels,
    [string]$WindowsIP = "192.168.1.107"  # IP Mac для локального доступа (для справки)
)

$ErrorActionPreference = "Stop"
$Host.UI.RawUI.WindowTitle = "AI Agents Setup - Windows (Auto-Installer)"

# ============================================================================
#  ПРОВЕРКА АДМИНИСТРАТОРСКИХ ПРАВ
# ============================================================================

function Test-Administrator
{
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Administrator))
{
    Write-Host "❌ ОШИБКА: Скрипт должен быть запущен от имени администратора!" -ForegroundColor Red
    Write-Host "`n📝 Как запустить:" -ForegroundColor Yellow
    Write-Host "1. Нажмите Win + X → Windows PowerShell (Admin)" -ForegroundColor Gray
    Write-Host "2. Перейдите в папку проекта: cd C:\путь\к\chat\windows" -ForegroundColor Gray
    Write-Host "3. Запустите: .\setup.ps1" -ForegroundColor Gray
    exit 1
}

# ============================================================================
#  АВТОМАТИЧЕСКАЯ УСТАНОВКА NODE.JS
# ============================================================================

function Test-NodeJS
{
    $node = Get-Command node -ErrorAction SilentlyContinue
    if ($null -eq $node)
    {
        return $false
    }

    try
    {
        $version = (node --version).Trim()
        Write-Host "✅ Node.js установлен: v$version" -ForegroundColor Green
        return $true
    }
    catch
    {
        return $false
    }
}

function Install-NodeJS
{
    Write-Host "`n📦 Установка Node.js..." -ForegroundColor Cyan

    # Скачиваем установщик (последняя LTS версия)
    $installerUrl = "https://nodejs.org/dist/v20.11.0/node-v20.11.0-x64.msi"
    $installerPath = "$env:TEMP\node-installer.msi"

    Write-Host "   [1/3] Скачивание установщика..." -ForegroundColor Yellow
    try
    {
        Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath -UseBasicParsing
    }
    catch
    {
        Write-Host "❌ Не удалось скачать Node.js: $_" -ForegroundColor Red
        return $false
    }

    Write-Host "   [2/3] Установка..." -ForegroundColor Yellow
    # Устанавливаем silently (без диалога)
    Start-Process msiexec.exe -ArgumentList "/i `"$installerPath`" /quiet /qn /norestart" -Wait

    Write-Host "   [3/3] Проверка установки..." -ForegroundColor Yellow
    Remove-Item $installerPath -Force 2> $null

    # Проверяем, что установилось
    Start-Sleep -Seconds 2
    if (Test-NodeJS)
    {
        Write-Host "✅ Node.js успешно установлен!" -ForegroundColor Green
        return $true
    }
    else
    {
        Write-Host "❌ Установка Node.js не удалась" -ForegroundColor Red
        return $false
    }
}

# ============================================================================
#  АВТОМАТИЧЕСКАЯ УСТАНОВКА OLLAMA
# ============================================================================

function Test-Ollama
{
    try
    {
        $version = ollama --version 2> $null
        if ($null -eq $version)
        {
            throw
        }
        Write-Host "✅ Ollama установлен: $version" -ForegroundColor Green
        return $true
    }
    catch
    {
        return $false
    }
}

function Install-Ollama
{
    Write-Host "`n🤖 Установка Ollama..." -ForegroundColor Cyan

    # Скачиваем установщик с официального сайта
    $installerUrl = "https://ollama.com/download/OllamaSetup.exe"
    $installerPath = "$env:TEMP\ollama-installer.exe"

    Write-Host "   [1/3] Скачивание установщика..." -ForegroundColor Yellow
    try
    {
        Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath -UseBasicParsing
    }
    catch
    {
        Write-Host "❌ Не удалось скачать Ollama: $_" -ForegroundColor Red
        return $false
    }

    Write-Host "   [2/3] Установка..." -ForegroundColor Yellow
    # Устанавливаем silently (без диалога)
    Start-Process $installerPath -ArgumentList "/S" -Wait

    Write-Host "   [3/3] Проверка установки..." -ForegroundColor Yellow
    Remove-Item $installerPath -Force 2> $null

    # Ждём пока Ollama инициализируется
    Start-Sleep -Seconds 5

    if (Test-Ollama)
    {
        Write-Host "✅ Ollama успешно установлен!" -ForegroundColor Green

        # Запускаем службу Ollama если не запущена
        try
        {
            $ollamaRunning = Get-Process ollama -ErrorAction SilentlyContinue
            if (-not $ollamaRunning)
            {
                Write-Host "   ℹ️  Запуск службы Ollama..." -ForegroundColor Yellow
                Start-Sleep -Seconds 2
                ollama serve &> $null
            }
        }
        catch
        {
            # Игнорируем если служба уже запущена
        }

        return $true
    }
    else
    {
        Write-Host "❌ Установка Ollama не удалась" -ForegroundColor Red
        return $false
    }
}

# ============================================================================
#  ПРОВЕРКА И УСТАНОВКА ЗАВИСИМОСТЕЙ
# ============================================================================

Write-Host "`n🔍 Проверка предварительных требований..." -ForegroundColor Cyan

$hasNode = Test-NodeJS
$hasOllama = Test-Ollama

if (-not $hasNode)
{
    Write-Host "⚠️  Node.js не найден. Начинаем установку..." -ForegroundColor Yellow
    if (-not (Install-NodeJS))
    {
        Write-Host "`n❌ КРИТИЧЕСКАЯ ОШИБКА: Не удалось установить Node.js" -ForegroundColor Red
        exit 1
    }
}

if (-not $hasOllama)
{
    Write-Host "⚠️  Ollama не найден. Начинаем установку..." -ForegroundColor Yellow
    if (-not (Install-Ollama))
    {
        Write-Host "`n❌ КРИТИЧЕСКАЯ ОШИБКА: Не удалось установить Ollama" -ForegroundColor Red
        exit 1
    }
}

# ============================================================================
#  СОЗДАНИЕ СТРУКТУРЫ ПАПОК
# ============================================================================

Write-Host "`n📁 Создание структуры папок..." -ForegroundColor Cyan

$BasePath = "C:\ai-services"
$McpPath = "$BasePath\mcp"
$DataPath = "$McpPath\data"
$LogsPath = "$McpPath\logs"

New-Item -ItemType Directory -Force -Path $BasePath | Out-Null
New-Item -ItemType Directory -Force -Path $McpPath | Out-Null
New-Item -ItemType Directory -Force -Path $DataPath | Out-Null
New-Item -ItemType Directory -Force -Path $LogsPath | Out-Null

Write-Host "✅ Папки созданы:" -ForegroundColor Green
Write-Host "   - $McpPath" -ForegroundColor Gray
Write-Host "   - $DataPath" -ForegroundColor Gray
Write-Host "   - $LogsPath" -ForegroundColor Gray

# ============================================================================
#  СОЗДАНИЕ ВСПОМОГАТЕЛЬНЫХ ФАЙЛОВ
# ============================================================================

Write-Host "`n📝 Создание вспомогательных файлов..." -ForegroundColor Cyan

# start-mcp.bat
$batContent = @'
@echo off
setlocal enabledelayedexpansion
if not exist "..\data" mkdir ..\data
if not exist "..\logs" mkdir ..\logs
echo [INFO] Запуск MCP Memory Server...
npx -y @modelcontextprotocol/server-memory > ..\logs\mcp.log 2>&1 & echo [PID] !errorlevel!
pause
'@
Set-Content -Path "$McpPath\start-mcp.bat" -Value $batContent

# ollama-config.json
$ollamaConfig = @'
{
    "hosts": ["0.0.0.0:11434"]
}
'@
Set-Content -Path "$McpPath\config.json" -Value $ollamaConfig

Write-Host "✅ Файлы созданы:" -ForegroundColor Green
Write-Host "   - start-mcp.bat" -ForegroundColor Gray
Write-Host "   - config.json" -ForegroundColor Gray

# ============================================================================
#  НАСТРОЙКА ФАЕРВОЛА
# ============================================================================

Write-Host "`n🔌 Настройка фаервола..." -ForegroundColor Cyan

$firewallRules = @(
    @{ Name = "AI MCP Server"; Port = 3000; Protocol = "TCP" },
    @{ Name = "AI Ollama API"; Port = 11434; Protocol = "TCP" }
)

foreach ($rule in $firewallRules)
{
    $existingRule = netsh advfirewall firewall show rule name="$( $rule.Name )" 2> $null

    if (-not $existingRule -or $LASTEXITCODE -ne 0)
    {
        Write-Host "   [1/2] Добавляем правило: $( $rule.Name ) (порт $( $rule.Port ))..." -ForegroundColor Yellow
        netsh advfirewall firewall add rule name="$( $rule.Name )" dir=in action=allow protocol=$( $rule.Protocol ) localport=$( $rule.Port ) 2> $null

        if ($LASTEXITCODE -eq 0)
        {
            Write-Host "   ✅ Правило добавлено" -ForegroundColor Green
        }
        else
        {
            Write-Host "   ⚠️  Не удалось добавить правило (возможно, уже существует)" -ForegroundColor Yellow
        }
    }
    else
    {
        Write-Host "   ℹ️  Правило $( $rule.Name ) уже существует" -ForegroundColor Gray
    }
}

# ============================================================================
#  ЗАГРУЗКА МОДЕЛЕЙ OLLAMA (Worker модели для Continue.dev)
# ============================================================================

if (-not $SkipInstallModels)
{
    Write-Host "`n🤖 Загрузка моделей Ollama (Worker модели для AI-ассистента Qwen3.5-35B на Mac)..." -ForegroundColor Cyan

    $models = @(
        @{ Name = "qwen2.5-coder:14b"; Size = "~7GB"; Role = "Developer Worker" },
        @{ Name = "llama3.1:8b"; Size = "~5GB"; Role = "QA Worker" }
    )

    foreach ($model in $models)
    {
        Write-Host "`n   [1/$( ($models.Count) )] Загрузка модели: $( $model.Name )" -ForegroundColor Yellow

        # Проверяем, установлена ли модель
        $installedModels = ollama list 2> $null | Select-String "^\s*$( ($model.Name).Split(':')[0] )"

        if ($installedModels)
        {
            Write-Host "   ℹ️  Модель $( $model.Name ) уже установлена" -ForegroundColor Gray
            continue
        }

        # Загружаем модель с отображением прогресса
        try
        {
            $output = ollama pull $( $model.Name ) 2>&1

            if ($LASTEXITCODE -eq 0)
            {
                Write-Host "   ✅ Модель $( $model.Name ) загружена (~$( $model.Size ))" -ForegroundColor Green
            }
            else
            {
                Write-Host "   ❌ Ошибка загрузки модели $( $model.Name )" -ForegroundColor Red
            }
        }
        catch
        {
            Write-Host "   ⚠️  Не удалось загрузить модель: $_" -ForegroundColor Yellow
        }
    }
}

# ============================================================================
#  ПРОВЕРКА И ФИНАЛИЗАЦИЯ
# ============================================================================

Write-Host "`n🔍 Проверка установки..." -ForegroundColor Cyan

$ollamaList = ollama list 2> $null | Select-String "qwen2.5-coder|llama3.1"
if ($ollamaList)
{
    Write-Host "✅ Модели Ollama (Worker модели для AI-ассистента):" -ForegroundColor Green
    $ollamaList | ForEach-Object { Write-Host "   $_" -ForegroundColor Gray }
}
else
{
    Write-Host "⚠️  Модели не найдены (возможно, SkipInstallModels)" -ForegroundColor Yellow
}

# Проверка портов
$listeningPorts = netstat -ano | Select-String ":11434|:3000"
if ($listeningPorts)
{
    Write-Host "✅ Порты в режиме прослушивания:" -ForegroundColor Green
    $listeningPorts | ForEach-Object { Write-Host "   $_" -ForegroundColor Gray }
}
else
{
    Write-Host "ℹ️  Сервисы пока не запущены (запустите start-mcp.bat)" -ForegroundColor Yellow
}

# ============================================================================
#  ФИНАЛЬНЫЕ ИНСТРУКЦИИ
# ============================================================================

Write-Host "`n" + ("=" * 60) -ForegroundColor Cyan
Write-Host "✅ НАСТРОЙКА ЗАВЕРШЕНА!" -ForegroundColor Green
Write-Host ("=" * 60) -ForegroundColor Cyan

Write-Host "`n📝 Архитектура системы:" -ForegroundColor Yellow
Write-Host "   Core AI (Mac): Qwen3.5-35B через LM Studio (:1234)" -ForegroundColor White
Write-Host "   Worker Models (Win): qwen2.5-coder:14b, llama3.1:8b (:11434)" -ForegroundColor White

Write-Host "`n📝 Следующие шаги:" -ForegroundColor Yellow
Write-Host "1. Запустите MCP сервер на Windows:" -ForegroundColor White
Write-Host "   C:\ai-services\mcp\start-mcp.bat" -ForegroundColor Gray
Write-Host "2. Настройте Mac (AI-ассистент Qwen3.5-35B):" -ForegroundColor White
Write-Host "   cp macos/continue/config.json ~/.continue/" -ForegroundColor Gray
Write-Host "   cp macos/mcp-proxy/* ~/.continue/mcp-proxy/" -ForegroundColor Gray
Write-Host "3. Проверьте связь с Mac:" -ForegroundColor White
Write-Host "   curl http://192.168.1.107:11434/api/tags" -ForegroundColor Gray

Write-Host "`n📁 Структура папок Windows:" -ForegroundColor Yellow
Write-Host "C:\ai-services\" -ForegroundColor White
Write-Host "├── mcp\" -ForegroundColor White
Write-Host "│   ├── start-mcp.bat" -ForegroundColor Gray
Write-Host "│   ├── config.json" -ForegroundColor Gray
Write-Host "│   ├── data\" -ForegroundColor Gray
Write-Host "│   └── logs\" -ForegroundColor Gray

Write-Host "`n⚠️  Важно:" -ForegroundColor Yellow
Write-Host "- Скрипт настроил фаервол для портов 3000 и 11434" -ForegroundColor White
Write-Host "- Worker модели загружены в ~/.ollama/models (или C:\Users\<User>\.ollama\models)" -ForegroundColor White
Write-Host "- Core модель Qwen3.5-35B работает на Mac через LM Studio (:1234)" -ForegroundColor White

Write-Host "`n🎉 Готово к работе с AI-ассистентом!" -ForegroundColor Green
