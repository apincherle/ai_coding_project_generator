# Dependency Policy - Python

Use uv with a committed lock file and approved Python indexes.
Pin direct and transitive dependencies through the lock file.
Justify additions, review licence/provenance/CVEs and reject unmaintained packages.
Do not execute dependency install scripts from untrusted sources.
Approved local container tooling: Docker Engine, Docker Compose, and Dev Containers. The Python template
pins ``ghcr.io/astral-sh/uv``, bakes ruff/mypy/pytest/pre-commit into the ``development`` image via
``uv sync --locked``, and ships a committed ``uv.lock``. Keep secrets out of Git.
