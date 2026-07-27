---
name: generate-dotnet-tests
description: Create or improve C# tests using xUnit, NSubstitute, FluentAssertions, WebApplicationFactory, EF Core or Testcontainers. Use for unit, API, integration, regression, validation or security tests governed by repository Markdown context.
---

# Generate .NET Tests

## Product context requirement

Before acting, read `.ai/generation.json`, resolve its `projectContextFile`, and read that root product
context file completely. If no generation record exists, locate the single root `<ProjectName>.md` product
context file or ask the user which product context applies. This requirement is in addition to `AGENTS.md`
and the applicable `.ai/*.md` files.

Read and obey `.ai/version-control-policy.md`. Never stage, commit, push, change branches, rewrite history,
or open/merge a pull request. Leave changes uncommitted for a human or approved IDE workflow.

Read `AGENTS.md`, `.ai/project.md`, `.ai/testing.md`, `.ai/architecture.md`,
`.ai/coding-standards.md`, `.ai/security.md` and relevant domain guidance completely.
Inspect production code, existing tests, project files and fixtures.

Use only test libraries/tools approved by `.ai/testing.md`, `.ai/dependencies.md` and
`.ai/tooling-policy.md`. If no approved tool covers the requirement, ask before adding one and update context,
project files, lockfile and CI only when approved as an ongoing standard.

Identify observable behaviours and choose the lowest-cost test that proves each one.
Substitute external boundaries, not records/value objects or every internal service.
Cover positive, negative, validation, cancellation, exception and boundary cases.

Every test must contain a meaningful FluentAssertions or xUnit assertion about value, state, response,
persisted effect or exception. Received-call verification alone is insufficient.

Run targeted tests, then the applicable suite. Report behaviours covered, commands/outcomes and gaps.
