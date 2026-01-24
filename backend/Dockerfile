FROM python:3.14-slim-bookworm
COPY --from=ghcr.io/astral-sh/uv:0.9.26 /uv /bin/uv

# Sync the project into a new environment, using the frozen lockfile
WORKDIR /app/backend
COPY . /app/backend

# psycopg2 ビルドに必要なパッケージをインストール
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    libxcb1 \
    postgresql-client \
    && uv sync --dev \
    && apt-get purge -y build-essential libpq-dev \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*
