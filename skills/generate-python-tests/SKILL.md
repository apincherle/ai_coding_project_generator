---
name: generate-python-tests
description: Create or improve Python tests using pytest, unittest.mock, HTTPX, FastAPI TestClient, property tests, or Testcontainers. Use for unit, API, integration, regression, validation, or security tests governed by repository Markdown context.
---

# Generate Python Tests

## Product context requirement

Before acting, read `.ai/generation.json`, resolve its `projectContextFile`, and read that root product
context file completely. If no generation record exists, locate the single root `<ProjectName>.md` product
context file or ask the user which product context applies. This requirement is in addition to `AGENTS.md`
and the applicable `.ai/*.md` files.

Read and obey `.ai/version-control-policy.md`. Never stage, commit, push, change branches, rewrite history,
or open/merge a pull request. Leave changes uncommitted for a human or approved IDE workflow.

Read `AGENTS.md`, `.ai/project.md`, `.ai/testing.md`, `.ai/architecture.md`,
`.ai/coding-standards.md`, `.ai/security.md` and relevant domain guidance completely.
Inspect production code, existing fixtures, tests and `pyproject.toml`.

Use only test libraries/tools approved by `.ai/testing.md`, `.ai/dependencies.md` and
`.ai/tooling-policy.md`. If no approved tool covers the requirement, ask before adding one and update context,
`pyproject.toml`, lockfile and CI only when approved as an ongoing standard.

Identify observable behaviours and choose the lowest-cost test that proves each one.
Mock external boundaries, not value objects or every internal function. Keep fixtures explicit and narrowly scoped.
Cover positive, negative, validation, exception and boundary cases.
Create fresh app and dependency state per test/fixture scope. Add coverage for rejected unknown Pydantic fields.
Flag tests that rely on mutable module globals, execution order or leaked dependency overrides.

Every test must contain a meaningful `assert` about a value, state, response, persisted effect or exception.
Mock-call verification alone is insufficient. Avoid sleeps, uncontrolled randomness and global-state leakage.

Run targeted pytest tests, then the applicable suite. Report behaviours covered, commands/outcomes and gaps.
