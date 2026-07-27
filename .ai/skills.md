# Reusable AI Workflows

A skill is a version-controlled procedure invoked by name. Each skill must define inputs, context files,
ordered actions, stop conditions, validation, and output format.

## `create-spring-endpoint`
Read project, architecture, API, security, and testing guidance; confirm contract; create DTO/controller/service/
repository changes; add validation, OpenAPI, unit and integration tests; run `mvn verify`; report evidence.

## `generate-tests`
Read testing guidance; identify behaviours and boundaries; create positive, negative, and edge cases; mock only
external collaborators; ensure every test has a real AssertJ assertion; run targeted tests.

## `review-pr`
Read governance and standards; inspect diff; check architecture, security, API compatibility, logging,
dependencies, error handling, and test quality; return findings ordered by severity with file/line references.

## `secure-review`
Identify trust boundaries, data classification, authn/authz, injection, SSRF, secrets, logging, dependencies,
and abuse cases. Stop and escalate on high-risk ambiguity.

Store tool-specific wrappers in `.cursor/rules`, `.github/copilot-instructions.md`, `CLAUDE.md`, and `AGENTS.md`;
keep this file authoritative so behaviour does not drift across tools.

## Installable skill library

Complete Codex skills are stored under `skills/`:

- `create-spring-feature`
- `generate-java-tests`
- `review-java-change`
- `diagnose-java-failure`
- `refactor-java-code`
- `secure-java-review`

Each skill locates the repository root and reads the applicable `.ai/*.md` files completely before acting.
To make them available in Codex, copy each skill folder into the active Codex skills directory, or install
them through your organisation's approved skill distribution process. Invoke one explicitly with syntax such as:

```text
Use $create-spring-feature to add a customer search endpoint.
Use $generate-java-tests to cover CustomerService failure paths.
Use $review-java-change to review this pull request.
```

Keep project-specific facts in `.ai/*.md`, not inside the skills. This allows one reusable skill library to
operate consistently across repositories while consuming each repository's own architecture, security,
testing, business, and dependency rules.

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
