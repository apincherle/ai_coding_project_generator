# Project Context - Python Profile

Baseline: Python 3.13, FastAPI, uv, Pydantic, SQLAlchemy/Alembic, REST/JSON and PostgreSQL.
Testing: pytest, unittest.mock, HTTPX and Testcontainers.
Quality: Ruff formatting/linting, mypy, coverage, dependency scanning, Bandit or Semgrep.
Containers: multistage Dockerfile with pinned ``ghcr.io/astral-sh/uv`` tooling, a ``development``
stage that bakes ruff/mypy/pytest/pre-commit, Compose ``target: development``, and a Dev Container
that attaches to that image.

Use Pydantic models for API requests/responses, configuration and validated integration boundaries.
Construct the application through a factory and inject dependencies explicitly. Mutable module-level
repositories, service instances, caches, clients and configuration are prohibited.

Replace this paragraph with the product purpose, owners, data classification, integrations and constraints.
AI may implement scoped changes, but a named human owns requirements, review and merge.
