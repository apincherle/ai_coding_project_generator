# syntax=docker/dockerfile:1
# hadolint global ignore=DL3008

ARG PYTHON_VERSION=3.13
ARG UV_VERSION=0.8.12
ARG BASE_IMAGE=python:${PYTHON_VERSION}-slim
ARG UID=10001
ARG GID=10001
ARG PORT=8000

# =============================================================================
# Pre-built uv binary (pinned)
# =============================================================================
FROM ghcr.io/astral-sh/uv:${UV_VERSION} AS uv

# =============================================================================
# Build - production virtualenv
# =============================================================================
FROM ${BASE_IMAGE} AS build
ENV UV_LINK_MODE=copy \
    UV_COMPILE_BYTECODE=1 \
    UV_PYTHON_DOWNLOADS=never \
    UV_PYTHON=python3.13 \
    UV_PROJECT_ENVIRONMENT=/app
COPY --from=uv /uv /bin/uv
WORKDIR /src
RUN --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    --mount=type=bind,source=README.md,target=README.md \
    uv sync --locked --no-dev --no-install-project
COPY src ./src
COPY pyproject.toml README.md uv.lock ./
RUN uv sync --locked --no-dev --no-editable

# =============================================================================
# Development - toolchain baked in (ruff, mypy, pytest, uv)
# =============================================================================
FROM ${BASE_IMAGE} AS development
ARG UID GID PORT
ENV UV_LINK_MODE=copy \
    UV_COMPILE_BYTECODE=1 \
    UV_PYTHON_DOWNLOADS=never \
    UV_PYTHON=python3.13 \
    UV_PROJECT_ENVIRONMENT=/app \
    PATH="/app/.venv/bin:$PATH" \
    PORT=${PORT} \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1
COPY --from=uv /uv /bin/uv
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      git \
      tini \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && groupadd -g "${GID}" app \
 && useradd -l -u "${UID}" -g "${GID}" -m -s /bin/bash app
WORKDIR /app
COPY --chown=app:app pyproject.toml README.md uv.lock ./
COPY --chown=app:app src ./src
COPY --chown=app:app tests ./tests
COPY --chown=app:app scripts/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh \
 && uv sync --locked \
 && chown -R app:app /app
USER app
EXPOSE ${PORT}
ENTRYPOINT ["/usr/bin/tini", "--", "/docker-entrypoint.sh"]
CMD ["sh", "-c", "uvicorn customer_api.main:app --host 0.0.0.0 --port ${PORT} --reload"]

# =============================================================================
# Production - minimal runtime (default)
# =============================================================================
FROM ${BASE_IMAGE} AS production
ARG UID GID PORT
ENV PATH="/app/bin:/app/.venv/bin:$PATH" \
    PORT=${PORT} \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl tini \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && groupadd -g "${GID}" -r app \
 && useradd -l -u "${UID}" -g "${GID}" -r -m -N app
COPY --from=build --chown=app:app /app /app
COPY --chown=app:app scripts/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
USER app
WORKDIR /app
EXPOSE ${PORT}
# Use the stdlib rather than adding curl, keeping this runtime image minimal.
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD python -c "import os,sys,urllib.request; urllib.request.urlopen(f'http://127.0.0.1:{os.environ[\"PORT\"]}/health', timeout=3)" || exit 1
ENTRYPOINT ["/usr/bin/tini", "--", "/docker-entrypoint.sh"]
CMD ["sh", "-c", "uvicorn customer_api.main:app --host 0.0.0.0 --port ${PORT}"]
