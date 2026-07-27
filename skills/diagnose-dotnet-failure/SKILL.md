---
name: diagnose-dotnet-failure
description: Diagnose a C#, ASP.NET Core, .NET build, xUnit, CI, container, or runtime failure using evidence and repository context. Use when Codex must explain a failure or find its root cause; do not implement a fix unless the request includes fixing it.
---

# Diagnose a .NET Failure

## Product context requirement

Before acting, read `.ai/generation.json`, resolve its `projectContextFile`, and read that root product
context file completely. If no generation record exists, locate the single root `<ProjectName>.md` product
context file or ask the user which product context applies. This requirement is in addition to `AGENTS.md`
and the applicable `.ai/*.md` files.

Read and obey `.ai/version-control-policy.md`. Use Git read-only; never stage, commit, push, change branches,
rewrite history, or open/merge a pull request. If a fix is requested, leave it uncommitted for a human.

## Load context

Locate the repository root. Read `AGENTS.md`, `.ai/project.md`, `.ai/architecture.md`,
`.ai/coding-standards.md`, `.ai/testing.md`, `.ai/security.md`, `.ai/dependencies.md` and
`.ai/tooling-policy.md` completely. Inspect the `.slnx`/csproj files, `Directory.Build.props`,
`packages.lock.json` (if present), application/configuration code, tests, the recent diff, and logs.

## Diagnose

1. Record the exact symptom, environment, command, and the first relevant exception or build error.
2. Reproduce with the narrowest safe command (`dotnet build -warnaserror`, `dotnet test --filter ...`,
   `dotnet format --verify-no-changes`, or a single request against the running app) when possible.
3. Separate the primary failure from cascading analyzer/build/test noise.
4. Form ranked hypotheses (application code, DI wiring, nullable-reference violations, analyzer/warnings-as-
   errors, dependency version drift, async/cancellation behaviour, container/image, CI runner) and test them
   with read-only inspection.
5. Identify the root cause only when evidence distinguishes it from alternatives.
6. Assess whether the failure indicates a security, data-integrity, compatibility, or deployment risk,
   including a NuGet audit finding (`NU1901`-`NU1904`) surfaced during restore.

Do not change code during a diagnosis-only request. Do not hide uncertainty or recommend deleting checks,
disabling `TreatWarningsAsErrors`, or lowering the coverage threshold in `coverlet.runsettings`.

## Report

Provide:

- observed symptom and reproduction status;
- root cause with concrete evidence (build/test output, stack frame, diff line);
- rejected alternatives;
- smallest safe fix and regression-test requirement;
- any missing access, environment, or evidence.

If asked to fix, apply the smallest change, add a meaningful regression assertion, and run
`dotnet format --verify-no-changes`, `dotnet build -warnaserror`, and
`dotnet test --collect:"XPlat Code Coverage" --settings coverlet.runsettings`.
