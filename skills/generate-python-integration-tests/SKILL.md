---
name: generate-python-integration-tests
description: Create or repair Python integration tests that exercise the FastAPI app, wiring, and real or containerized dependencies end to end. Use for API-boundary, persistence, or cross-module integration coverage, distinct from isolated unit tests.
---

# Generate Python Integration Tests

## Product context requirement

Before acting, read `.ai/generation.json`, resolve its `projectContextFile`, and read that root product
context file completely. If no generation record exists, locate the single root `<ProjectName>.md` product
context file or ask the user which product context applies. This requirement is in addition to `AGENTS.md`
and the applicable `.ai/*.md` files.

Read and obey `.ai/version-control-policy.md`. Never stage, commit, push, change branches, rewrite history,
or open/merge a pull request. Leave changes uncommitted for a human or approved IDE workflow.

Read `AGENTS.md`, `.ai/project.md`, `.ai/testing.md`, `.ai/architecture.md`, `.ai/coding-standards.md`,
`.ai/api-guidelines.md`, `.ai/security.md` and relevant domain guidance completely. Inspect the application
factory, route wiring, repository/persistence implementations, `pyproject.toml`, and existing tests.

Use only test libraries/tools approved by `.ai/testing.md`, `.ai/dependencies.md` and `.ai/tooling-policy.md`
(pytest, HTTPX, FastAPI `TestClient`/`ASGITransport`, and Testcontainers when a real datastore is present).
If no approved tool covers the requirement, ask before adding one and update context, `pyproject.toml`,
lockfile and CI only when approved as an ongoing standard.

## Build integration coverage

1. Exercise the wired application through `create_app(...)` rather than importing handlers directly; use a
   fresh app/client per test so state does not leak across tests.
2. Prefer real collaborators over mocks at this layer; substitute only true external boundaries (payment
   gateways, third-party APIs, clocks) explicitly permitted by `.ai/architecture.md`.
3. When persistence is backed by a real datastore, spin it up with Testcontainers and assert against actual
   round-tripped data, not mocked repository calls.
4. Cover the full request/response cycle: routing, Pydantic validation (including rejection of unexpected
   fields), status codes, error mapping, and response schema shape.
5. Cover cross-cutting behaviour introduced for production readiness (health/readiness endpoints,
   correlation-id propagation, request-size limits) when present.
6. Avoid sleeps, uncontrolled randomness, shared mutable fixtures, and assertions coupled to internal
   implementation details rather than observable behaviour.

Every test must contain a meaningful assertion on a response body, status code, persisted state, or raised
exception. Mock-call verification alone is insufficient.

## Validate and report

Run the new/targeted tests, then `uv run pytest` and `uv run mypy src`. Report which end-to-end behaviours
are now covered, commands/outcomes, and any integration path still relying on a unit-level double.
