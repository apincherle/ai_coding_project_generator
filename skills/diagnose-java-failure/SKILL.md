---
name: diagnose-java-failure
description: Diagnose a Java, Spring Boot, Maven, test, CI, database, container, or runtime failure using evidence and repository context. Use when Codex is asked to explain a failure or find its root cause; do not implement a fix unless the request includes fixing it.
---

# Diagnose a Java Failure

## Product context requirement

Before acting, read `.ai/generation.json`, resolve its `projectContextFile`, and read that root product
context file completely. If no generation record exists, locate the single root `<ProjectName>.md` product
context file or ask the user which product context applies. This requirement is in addition to `AGENTS.md`
and the applicable `.ai/*.md` files.

Read and obey `.ai/version-control-policy.md`. Use Git read-only; never stage, commit, push, change branches,
rewrite history, or open/merge a pull request. If a fix is requested, leave it uncommitted for a human.

## Load context

Locate the repository root. Read `AGENTS.md`, `.ai/project.md`, `.ai/architecture.md`,
`.ai/coding-standards.md`, `.ai/testing.md`, `.ai/security.md`, and relevant domain/dependency guidance completely.
Inspect build files, configuration, failing code, tests, recent diff, and available logs.

## Diagnose

1. Record the exact symptom, environment, command, and first relevant error.
2. Reproduce with the narrowest safe command when possible.
3. Separate primary failure from cascading messages.
4. Form ranked hypotheses and test them with read-only inspection or targeted diagnostics.
5. Identify the root cause only when evidence distinguishes it from alternatives.
6. Assess whether the failure indicates a security, data integrity, compatibility, or deployment risk.

Do not change code during a diagnosis-only request. Do not hide uncertainty or recommend deleting checks.

## Report

Provide:

- observed symptom and reproduction status;
- root cause with concrete evidence;
- rejected alternatives;
- smallest safe fix and regression-test requirement;
- any missing access, environment, or evidence.

If asked to fix, apply the smallest change, add a meaningful regression assertion, and run relevant verification.
