---
name: generate-dotnet-integration-tests
description: Create or repair C# integration tests that exercise the ASP.NET Core app, DI wiring, and real or containerized dependencies end to end. Use for API-boundary, persistence, or cross-module integration coverage, distinct from isolated unit tests.
---

# Generate .NET Integration Tests

## Product context requirement

Before acting, read `.ai/generation.json`, resolve its `projectContextFile`, and read that root product
context file completely. If no generation record exists, locate the single root `<ProjectName>.md` product
context file or ask the user which product context applies. This requirement is in addition to `AGENTS.md`
and the applicable `.ai/*.md` files.

Read and obey `.ai/version-control-policy.md`. Never stage, commit, push, change branches, rewrite history,
or open/merge a pull request. Leave changes uncommitted for a human or approved IDE workflow.

Read `AGENTS.md`, `.ai/project.md`, `.ai/testing.md`, `.ai/architecture.md`, `.ai/coding-standards.md`,
`.ai/api-guidelines.md`, `.ai/security.md` and relevant domain guidance completely. Inspect `Program.cs`
DI wiring, persistence implementations, project files, and existing tests.

Use only test libraries/tools approved by `.ai/testing.md`, `.ai/dependencies.md` and `.ai/tooling-policy.md`
(xUnit, `Microsoft.AspNetCore.Mvc.Testing`'s `WebApplicationFactory`, FluentAssertions, NSubstitute, and
Testcontainers when a real datastore is present). If no approved tool covers the requirement, ask before
adding one and update context, project files, lockfile and CI only when approved as an ongoing standard.

## Build integration coverage

1. Exercise the wired application through `WebApplicationFactory<Program>` rather than instantiating
   handlers directly; use a fresh factory/client per test so state does not leak across tests.
2. Prefer real collaborators over substitutes at this layer; substitute only true external boundaries
   explicitly permitted by `.ai/architecture.md`.
3. When persistence is backed by a real datastore, spin it up with Testcontainers and assert against actual
   round-tripped data, not substituted repository calls.
4. Cover the full request/response cycle: routing, model validation, status codes, Problem Details error
   mapping, and response schema shape.
5. Cover cross-cutting behaviour introduced for production readiness (health endpoints, correlation-id
   propagation) when present.
6. Avoid sleeps, uncontrolled randomness, shared mutable fixtures, and assertions coupled to internal
   implementation details rather than observable behaviour.

Every test must contain a meaningful FluentAssertions/xUnit assertion on a response body, status code,
persisted state, or thrown exception. Received-call verification alone is insufficient.

## Validate and report

Run the new/targeted tests, then `dotnet test --collect:"XPlat Code Coverage" --settings coverlet.runsettings`
and `dotnet build -warnaserror`. Report which end-to-end behaviours are now covered, commands/outcomes, and
any integration path still relying on a unit-level substitute.
