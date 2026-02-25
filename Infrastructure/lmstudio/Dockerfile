# LM Studio headless server (llmster) Dockerfile
# https://lmstudio.ai/docs/developer#install-llmster-for-headless-deployments

FROM ubuntu:22.04

# Установка базовых зависимостей
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Установка llmster (LM Studio CLI)
RUN curl -fsSL https://lmstudio.ai/install.sh | bash

# Проверка установки
RUN lms --version

# Порт по умолчанию для LM Studio server
EXPOSE 1234

# Переменные окружения
ENV LM_API_PORT=1234
ENV LM_API_HOST=0.0.0.0

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD lms ps || exit 1

# Запуск llmster daemon и сервера
# daemon загружает CLI, server start запускает HTTP сервер
CMD ["sh", "-c", "lms daemon up && lms server start --host $LM_API_HOST --port $LM_API_PORT"]
