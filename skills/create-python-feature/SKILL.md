---
name: create-python-feature
description: Implement or extend a typed Python or FastAPI feature, endpoint, service, repository, validation model, migration, or integration. Use when Codex must build production Python code under repository AGENTS.md and .ai Markdown standards.
---

# Create a Python Feature

Read and obey `.ai/version-control-policy.md`. Never stage, commit, push, change branches, rewrite history,
or open/merge a pull request. Leave changes uncommitted for a human or approved IDE workflow.

Locate the repository root. Read `AGENTS.md`, `.ai/project.md`, `.ai/architecture.md`,
`.ai/coding-standards.md`, `.ai/api-guidelines.md`, `.ai/security.md`, `.ai/testing.md`,
`.ai/business-rules.md`, `.ai/domain-model.md` and `.ai/dependencies.md` completely.
Read nearby code, tests, configuration and ADRs.

Before adding or replacing any package/tool, read `.ai/tooling-policy.md` and `.ai/dependencies.md`.
Use the documented choice. If none exists, stop and ask the user before adding it. Ask whether the approved
choice is task-local or an ongoing standard; for an ongoing standard, update relevant `.ai` context,
`pyproject.toml`, lockfile, CI and hooks in the same change.

1. Restate acceptance criteria, assumptions, scope and risk.
2. Stop when ambiguity materially affects API, data, authorization or architecture.
3. Implement the smallest vertical slice with strict Pydantic v2 request, response, settings and integration-boundary models.
4. Keep route handlers thin; put business behaviour in services/policies; isolate persistence and external clients.
5. Use an application factory and an explicit composition root. Do not add mutable module-global repositories, services, clients, caches, sessions or configuration.
6. Inject time, identifiers, randomness and external clients when behaviour depends on them.
7. Configure Pydantic boundary models to reject unexpected input unless the contract explicitly permits it.
8. Use protocols only at real boundaries. Prefer concrete internal types and pure responsibility-named functions.
9. Add pytest unit and appropriate API/integration tests with fresh state.
10. Require a meaningful outcome assertion in every test; mock-call checks alone are insufficient.
11. Run Ruff formatting/linting, mypy and pytest using repository commands.

Report changed files, decisions, checks/outcomes, unverified items and residual risk.
