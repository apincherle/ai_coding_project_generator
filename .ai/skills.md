# Reusable AI Workflows

A skill is a version-controlled procedure invoked by name. Each skill must define inputs, context files,
ordered actions, stop conditions, validation, and output format.

Store tool-specific wrappers in `.cursor/rules`, `.github/copilot-instructions.md`, `CLAUDE.md`, and `AGENTS.md`;
keep this file and the `skills/` folders authoritative so behaviour does not drift across tools.

Generic prompt outlines also live in `.ai/prompts.md`. Prefer a named skill from `skills/` when one exists.

## Presentation materials

- Standards briefing: `AI_Development_Standards_Handout.pdf`
- Skills briefing: `docs/AI-Development-Skills-User-Guide.pdf`
- Catalogue handbook: `docs/AI-Engineering-Starter-Kit-Handbook.pdf`
- Live demo prompts: `.ai/prompts.md`

The Markdown files in `docs/handouts/` are concise reference summaries. Branded PDFs are maintained
and visually reviewed through the approved document-authoring process.

## Installable skill library

Complete Codex skills are stored under `skills/`. Every skill locates the repository root and reads the
applicable `.ai/*.md` files completely before acting.

### Java / Spring Boot

- `create-spring-feature` — implement or extend a Spring Boot feature, endpoint, service, repository, DTO, or migration
- `generate-java-tests` — create or repair JUnit 5 / Mockito / AssertJ / Testcontainers tests with outcome assertions
- `review-java-change` — review a diff or PR for correctness, architecture, security, compatibility, and test quality
- `diagnose-java-failure` — diagnose build, test, CI, or runtime failures from evidence (fix only when asked)
- `refactor-java-code` — behaviour-preserving refactor for clarity, boundaries, and testability
- `secure-java-review` — risk-based security review against `.ai/security.md` and trust boundaries

### Python

- `create-python-feature` — implement or extend a typed Python / FastAPI feature
- `generate-python-tests` — create or repair pytest coverage with meaningful assertions
- `review-python-change` — review a Python change against repository standards
- `secure-python-review` — security-focused Python review

### C# / .NET

- `create-dotnet-feature` — implement or extend an ASP.NET Core / .NET feature
- `generate-dotnet-tests` — create or repair xUnit / NSubstitute / FluentAssertions tests
- `review-dotnet-change` — review a .NET change against repository standards
- `secure-dotnet-review` — security-focused .NET review

To make them available in Codex, copy each skill folder into the active Codex skills directory, or install
them through your organisation's approved skill distribution process. Invoke one explicitly with syntax such as:

```text
Use $create-spring-feature to add a customer search endpoint.
Use $generate-java-tests to cover CustomerService failure paths.
Use $review-java-change to review this pull request.
Use $create-python-feature to add a FastAPI search endpoint.
Use $create-dotnet-feature to add an ASP.NET Core search endpoint.
```

Keep project-specific facts in `.ai/*.md`, not inside the skills. This allows one reusable skill library to
operate consistently across repositories while consuming each repository's own architecture, security,
testing, business, and dependency rules.

Profiles without bundled skills (native, Node, React, Next.js) still use the active `.ai/*.md` context and
the generic workflows in `.ai/prompts.md` until stack-specific skills are added.

## Mandatory dependency behaviour

Every implementation, testing, refactoring and review skill must read `.ai/tooling-policy.md` and
`.ai/dependencies.md`. Skills must use context-approved libraries/tools. When no choice is documented, they
must pause before adding a dependency and ask the user for approval. If the approved choice will become a
project standard, the skill must update the relevant `.ai` files, manifest, lockfile and quality gates as
part of the same change.

## Mandatory version-control boundary

Every skill must read and obey `.ai/version-control-policy.md`. Skills may inspect Git state but must never
stage, commit, amend, tag, push, change branches, rewrite history, open or merge a pull request, or delegate
those actions. End with an uncommitted human handoff containing changed files and validation evidence.
