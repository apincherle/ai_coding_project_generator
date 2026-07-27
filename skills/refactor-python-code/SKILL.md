---
name: refactor-python-code
description: Refactor Python or FastAPI code to improve clarity, boundaries, duplication, or testability while preserving behaviour. Use when Codex is asked to clean up, simplify, reorganize, or modernize code under repository Markdown standards.
---

# Refactor Python Code

## Product context requirement

Before acting, read `.ai/generation.json`, resolve its `projectContextFile`, and read that root product
context file completely. If no generation record exists, locate the single root `<ProjectName>.md` product
context file or ask the user which product context applies. This requirement is in addition to `AGENTS.md`
and the applicable `.ai/*.md` files.

Read and obey `.ai/version-control-policy.md`. Never stage, commit, push, change branches, rewrite history,
or open/merge a pull request. Leave changes uncommitted for a human or approved IDE workflow.

## Load context and freeze behaviour

Locate the repository root. Read `AGENTS.md`, `.ai/project.md`, `.ai/architecture.md`,
`.ai/coding-standards.md`, `.ai/testing.md`, `.ai/api-guidelines.md` and relevant business/domain guidance
completely. Read callers, tests, route contracts, and ADRs.

Do not introduce a library or tool as part of refactoring unless it is already approved in
`.ai/dependencies.md`. Otherwise follow `.ai/tooling-policy.md`, stop and ask the user; update context and
`pyproject.toml`/lockfile/CI files only after approval as an ongoing standard.

1. State the behaviour and public contracts (routes, response models, exceptions) that must remain unchanged.
2. Identify the concrete maintainability problem and the smallest useful scope.
3. Add characterization tests when current behaviour is not protected.
4. Refactor in small coherent steps without mixing feature changes.
5. Preserve API schemas, status codes, error semantics, and observability unless explicitly approved.
6. Keep the domain/repository layers free of FastAPI/web imports; verify with `uv run lint-imports`.
7. Extract protocols only for a genuine external boundary; do not multiply interfaces mechanically.
8. Replace generic helpers with cohesive, responsibility-named collaborators when that improves the use-case flow.
9. Prefer pure functions, frozen dataclasses/Pydantic models, and injected boundary dependencies over static
   state, mutable module globals, or monkeypatching production code.

Every new or modified test must contain a meaningful outcome assertion.
Do not introduce a new dependency unless `.ai/dependencies.md` permits it and the benefit is explicit.

## Validate and report

Run `uv run ruff format --check .`, `uv run ruff check .`, `uv run mypy src`, `uv run lint-imports`, and
`uv run pytest`. Report the maintainability improvement, behaviour-preservation evidence, files changed,
commands and outcomes, and any contract not directly verified.
