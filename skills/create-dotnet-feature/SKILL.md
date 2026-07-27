---
name: create-dotnet-feature
description: Implement or extend a C# .NET or ASP.NET Core feature, endpoint, service, repository, validation model, EF Core migration, or integration. Use when Codex must build production .NET code under repository AGENTS.md and .ai Markdown standards.
---

# Create a .NET Feature

## Product context requirement

Before acting, read `.ai/generation.json`, resolve its `projectContextFile`, and read that root product
context file completely. If no generation record exists, locate the single root `<ProjectName>.md` product
context file or ask the user which product context applies. This requirement is in addition to `AGENTS.md`
and the applicable `.ai/*.md` files.

Read and obey `.ai/version-control-policy.md`. Never stage, commit, push, change branches, rewrite history,
or open/merge a pull request. Leave changes uncommitted for a human or approved IDE workflow.

Locate the repository root. Read `AGENTS.md`, `.ai/project.md`, `.ai/architecture.md`,
`.ai/coding-standards.md`, `.ai/api-guidelines.md`, `.ai/security.md`, `.ai/testing.md`,
`.ai/business-rules.md`, `.ai/domain-model.md` and `.ai/dependencies.md` completely.
Read nearby code, tests, project files and ADRs.

Before adding or replacing any package/tool, read `.ai/tooling-policy.md` and `.ai/dependencies.md`.
Use the documented choice. If none exists, stop and ask the user before adding it. Ask whether the approved
choice is task-local or an ongoing standard; for an ongoing standard, update relevant `.ai` context,
project/central package files, lockfile, CI and hooks in the same change.

1. Restate acceptance criteria, assumptions, scope and risk.
2. Stop when ambiguity materially affects API, data, authorization or architecture.
3. Implement the smallest vertical slice with nullable-reference safety and boundary validation.
4. Keep endpoints/controllers thin; place business behaviour in services/policies; isolate EF Core and external clients.
5. Use interfaces only at real boundaries. Prefer concrete internal services and focused collaborators.
6. Use async end to end for I/O and pass cancellation tokens where relevant.
7. Add xUnit tests with FluentAssertions and appropriate API/integration tests.
8. Require a meaningful outcome assertion in every test; substitute-call checks alone are insufficient.
9. Run format, build with warnings as errors and tests using repository commands.

Report changed files, decisions, checks/outcomes, unverified items and residual risk.
