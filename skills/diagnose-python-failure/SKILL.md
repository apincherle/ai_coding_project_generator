---
name: diagnose-python-failure
description: Diagnose a Python, FastAPI, uv, pytest, CI, container, or runtime failure using evidence and repository context. Use when Codex must explain a failure or find its root cause; do not implement a fix unless the request includes fixing it.
---

# Diagnose a Python Failure

## Product context requirement

Before acting, read `.ai/generation.json`, resolve its `projectContextFile`, and read that root product
context file completely. If no generation record exists, locate the single root `<ProjectName>.md` product
context file or ask the user which product context applies. This requirement is in addition to `AGENTS.md`
and the applicable `.ai/*.md` files.

Read and obey `.ai/version-control-policy.md`. Use Git read-only; never stage, commit, push, change branches,
rewrite history, or open/merge a pull request. If a fix is requested, leave it uncommitted for a human.

## Load context

Locate the repository root. Read `AGENTS.md`, `.ai/project.md`, `.ai/architecture.md`,
`.ai/coding-standards.md`, `.ai/testing.md`, `.ai/security.md`, `.ai/dependencies.md` and
`.ai/tooling-policy.md` completely. Inspect `pyproject.toml`, `uv.lock`, application/settings code, tests,
the recent diff, and any available logs or tracebacks.

## Diagnose

1. Record the exact symptom, environment, command, and the first relevant traceback frame or error.
2. Reproduce with the narrowest safe command (`uv run pytest -k ...`, `uv run mypy src`, `uv run ruff check .`,
   `uv run lint-imports`, `uv run pip-audit --local --skip-editable`, or a single `uvicorn` request) when possible.
3. Separate the primary failure from cascading pytest/mypy/ruff noise and dependency-resolution errors.
4. Form ranked hypotheses (application code, Pydantic validation, dependency version drift, async/event-loop
   behaviour, environment/config, container/image, CI runner) and test them with read-only inspection.
5. Identify the root cause only when evidence distinguishes it from alternatives.
6. Assess whether the failure indicates a security, data-integrity, compatibility, or deployment risk, and
   whether it stems from mutable module-global state or an unapproved dependency.

Do not change code during a diagnosis-only request. Do not hide uncertainty or recommend deleting checks,
lowering the coverage `fail_under` threshold, or skipping the import-linter contract.

## Report

Provide:

- observed symptom and reproduction status;
- root cause with concrete evidence (command output, stack frame, diff line);
- rejected alternatives;
- smallest safe fix and regression-test requirement;
- any missing access, environment, or evidence.

If asked to fix, apply the smallest change, add a meaningful regression assertion, and run
`uv run ruff format --check .`, `uv run ruff check .`, `uv run mypy src`, `uv run lint-imports`, and
`uv run pytest`.
