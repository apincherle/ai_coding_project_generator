---
name: refactor-dotnet-code
description: Refactor C# or ASP.NET Core code to improve clarity, boundaries, duplication, or testability while preserving behaviour. Use when Codex is asked to clean up, simplify, reorganize, or modernize code under repository Markdown standards.
---

# Refactor .NET Code

## Product context requirement

Before acting, read `.ai/generation.json`, resolve its `projectContextFile`, and read that root product
context file completely. If no generation record exists, locate the single root `<ProjectName>.md` product
context file or ask the user which product context applies. This requirement is in addition to `AGENTS.md`
and the applicable `.ai/*.md` files.

Read and obey `.ai/version-control-policy.md`. Never stage, commit, push, change branches, rewrite history,
or open/merge a pull request. Leave changes uncommitted for a human or approved IDE workflow.

## Load context and freeze behaviour

Locate the repository root. Read `AGENTS.md`, `.ai/project.md`, `.ai/architecture.md`,
`.ai/coding-standards.md`, `.ai/testing.md`, `.ai/api-guidelines.md`, and relevant business/domain guidance
completely. Read callers, tests, endpoint contracts, and ADRs.

Do not introduce a library or tool as part of refactoring unless it is already approved in
`.ai/dependencies.md`. Otherwise follow `.ai/tooling-policy.md`, stop and ask the user; update context,
project files, `packages.lock.json`, and CI only after approval as an ongoing standard.

1. State the behaviour and public contracts (endpoints, DTOs, status codes) that must remain unchanged.
2. Identify the concrete maintainability problem and the smallest useful scope.
3. Add characterization tests when current behaviour is not protected.
4. Refactor in small coherent steps without mixing feature changes.
5. Preserve API schemas, error semantics (Problem Details), and observability unless explicitly approved.
6. Keep nullable-reference safety and `TreatWarningsAsErrors` clean throughout the refactor.
7. Extract interfaces only for a genuine persistence/external-service boundary; do not multiply interfaces
   mechanically.
8. Replace generic helpers or extension-method dumping grounds with cohesive, responsibility-named
   collaborators when that improves the use-case flow.
9. Prefer concrete internal services, async end to end, and cancellation tokens at I/O boundaries over
   static state or ambient context.

Every new or modified test must contain a meaningful outcome assertion.
Do not introduce a new dependency unless `.ai/dependencies.md` permits it and the benefit is explicit.

## Validate and report

Run `dotnet format --verify-no-changes`, `dotnet build -warnaserror`, and
`dotnet test --collect:"XPlat Code Coverage" --settings coverlet.runsettings`. Report the maintainability
improvement, behaviour-preservation evidence, files changed, commands and outcomes, and any contract not
directly verified.
