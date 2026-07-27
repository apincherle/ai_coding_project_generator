---
name: create-spring-feature
description: Implement or extend a Java 21 Spring Boot feature, REST endpoint, service, repository, DTO, validation, OpenAPI contract, or database change. Use when Codex is asked to build production code in a repository that supplies project guidance through AGENTS.md and .ai Markdown context files.
---

# Create a Spring Feature

Read and obey `.ai/version-control-policy.md`. Never stage, commit, push, change branches, rewrite history,
or open/merge a pull request. Leave changes uncommitted for a human or approved IDE workflow.

## Load repository context

1. Locate the repository root containing `AGENTS.md` or `.ai/project.md`.
2. Read `AGENTS.md` completely when present.
3. Read these files completely before planning:
   - `.ai/project.md`
   - `.ai/architecture.md`
   - `.ai/coding-standards.md`
   - `.ai/api-guidelines.md`
   - `.ai/security.md`
   - `.ai/testing.md`
   - `.ai/business-rules.md`
   - `.ai/domain-model.md`
   - `.ai/dependencies.md`
4. Read relevant ADRs, nearby code, build configuration, and tests.
5. Treat repository context as authoritative. Report contradictions rather than choosing silently.

Before adding or replacing any library/tool, read `.ai/tooling-policy.md` and `.ai/dependencies.md`.
Use the documented choice. If none is specified, stop and ask the user before adding it. Ask whether an
approved choice is task-local or an ongoing standard; for an ongoing standard, update the applicable `.ai`
context, Maven configuration, lock/version policy, CI and hooks in the same change.

## Implement

1. Restate the acceptance criteria, assumptions, affected boundaries, and risk classification.
2. Stop for direction if a missing requirement would materially change the public API, data model, authorization, or architecture.
3. Design the smallest vertical slice that satisfies the requirement.
4. Keep controllers thin; place use-case logic in services; isolate persistence; keep entities out of API contracts.
5. Introduce interfaces only at genuine external or architectural boundaries. Do not create an interface for every service.
6. Extract a focused mapper, normalizer, validator, calculator, or policy when it represents a clear responsibility and improves the primary flow. Avoid generic helper or utility classes.
7. Prefer injected, deterministic collaborators to static access and static mocking.
8. Add boundary validation, stable error handling, OpenAPI updates, and a migration when the schema changes.
9. Add unit tests and appropriate integration or contract tests.
10. Ensure every test contains at least one meaningful state, value, result, or exception assertion. Never count `verify(...)` alone.

## Validate

Run the narrowest relevant tests first, then the repository verification command defined by its context or build. Do not weaken checks or delete tests to obtain a pass.

## Report

Return:

- requirement and risk summary;
- files changed and design decisions;
- tests and checks run with outcomes;
- assumptions, unverified items, and residual risks;
- any required reviewer or migration action.
