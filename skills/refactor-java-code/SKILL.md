---
name: refactor-java-code
description: Refactor Java or Spring Boot code to improve clarity, boundaries, duplication, testability, or maintainability while preserving behaviour. Use when Codex is asked to clean up, simplify, reorganize, or modernize code under repository Markdown standards.
---

# Refactor Java Code

Read and obey `.ai/version-control-policy.md`. Never stage, commit, push, change branches, rewrite history,
or open/merge a pull request. Leave changes uncommitted for a human or approved IDE workflow.

## Load context and freeze behaviour

Locate the repository root. Read `AGENTS.md`, `.ai/project.md`, `.ai/architecture.md`,
`.ai/coding-standards.md`, `.ai/testing.md`, `.ai/api-guidelines.md`, and relevant business/domain guidance completely.
Read callers, tests, API contracts, persistence mappings, and ADRs.

Do not introduce a library or tool as part of refactoring unless it is already approved in
`.ai/dependencies.md`. Otherwise follow `.ai/tooling-policy.md`, stop and ask the user; update context and
build/verification files only after approval as an ongoing standard.

1. State the behaviour and public contracts that must remain unchanged.
2. Identify the concrete maintainability problem and the smallest useful scope.
3. Add characterization tests when current behaviour is not protected.
4. Refactor in small coherent steps without mixing feature changes.
5. Preserve API schemas, error semantics, transactions, serialization, database behaviour, and observability unless explicitly approved.
6. Keep architectural dependencies aligned with `.ai/architecture.md`.
7. Extract interfaces only for meaningful substitution or architectural boundaries; do not multiply interfaces mechanically.
8. Replace generic helpers with cohesive, responsibility-named collaborators when that improves the use-case flow.
9. Prefer pure deterministic components and injected boundary dependencies over static state or static mocking.

Every new or modified test must contain a meaningful outcome assertion.
Do not introduce a new dependency unless `.ai/dependencies.md` permits it and the benefit is explicit.

## Validate and report

Run targeted tests and the repository verification command. Report the maintainability improvement,
behaviour-preservation evidence, files changed, commands and outcomes, and any contract not directly verified.
