---
name: generate-java-tests
description: Create, improve, or repair Java tests using JUnit 5, Mockito, AssertJ, Spring Boot Test, or Testcontainers. Use when Codex is asked for unit, integration, controller, repository, regression, or contract tests and must follow repository Markdown context.
---

# Generate Java Tests

## Product context requirement

Before acting, read `.ai/generation.json`, resolve its `projectContextFile`, and read that root product
context file completely. If no generation record exists, locate the single root `<ProjectName>.md` product
context file or ask the user which product context applies. This requirement is in addition to `AGENTS.md`
and the applicable `.ai/*.md` files.

Read and obey `.ai/version-control-policy.md`. Never stage, commit, push, change branches, rewrite history,
or open/merge a pull request. Leave changes uncommitted for a human or approved IDE workflow.

## Load repository context

Locate the repository root and read `AGENTS.md`, `.ai/project.md`, `.ai/testing.md`,
`.ai/architecture.md`, `.ai/coding-standards.md`, `.ai/security.md`, and relevant business/domain files completely.
Read the production code, existing test conventions, build configuration, and related tests before editing.

Use only test libraries/tools approved by `.ai/testing.md`, `.ai/dependencies.md` and
`.ai/tooling-policy.md`. If the required capability has no approved choice, ask the user before adding one.
When approved as an ongoing standard, update context and the Maven/CI configuration in the same change.

## Build the test model

1. Identify observable behaviours, inputs, outputs, state changes, errors, trust boundaries, and important regressions.
2. Select the lowest-cost test type that proves each behaviour.
3. Mock only external or slow collaborators. Do not mock value objects or the subject under test.
4. Use Arrange-Act-Assert and descriptive behaviour names.
5. Cover the happy path, relevant invalid input, missing data, failures, and boundary cases.
6. Use Testcontainers when real PostgreSQL semantics, migrations, mappings, or queries matter.

## Assertion rule

Every test must contain at least one meaningful outcome assertion using AssertJ or the repository-approved equivalent.
Assertions must inspect returned values, state, persisted data, HTTP contracts, or thrown errors.
Mock interaction verification may supplement an assertion but never replace it.

Reject sleeps, shared mutable fixtures, uncontrolled randomness, and tests that only prove implementation details.

## Validate and report

Run targeted tests, then the applicable test suite. Report behaviours covered, commands and outcomes,
remaining gaps, and any production defect revealed. Do not modify production behaviour merely to make a weak test pass.
