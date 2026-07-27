---
name: review-dotnet-migration
description: Review a .NET/NuGet dependency major-version upgrade, runtime upgrade, framework migration, or EF Core data/schema migration for compatibility, data safety, and rollback. Use for upgrade PRs or migration scripts under repository Markdown standards.
---

# Review a .NET Migration

## Product context requirement

Before acting, read `.ai/generation.json`, resolve its `projectContextFile`, and read that root product
context file completely. If no generation record exists, locate the single root `<ProjectName>.md` product
context file or ask the user which product context applies. This requirement is in addition to `AGENTS.md`
and the applicable `.ai/*.md` files.

Read and obey `.ai/version-control-policy.md`. Use Git read-only; never stage, commit, push, change branches,
rewrite history, or open/merge a pull request.

Read `AGENTS.md`, `.ai/dependencies.md`, `.ai/tooling-policy.md`, `.ai/testing.md`, `.ai/security.md`, and
`.ai/architecture.md` completely. Inspect the migration diff, project files, `packages.lock.json` (if
present), changelog/release notes for the upgraded component, and any EF Core migration files.

## Review order

1. **Compatibility** — breaking API/behaviour changes in the upgraded runtime, framework, or NuGet package;
   analyzer rule changes that now fail `TreatWarningsAsErrors`; nullable-reference annotation changes.
2. **Data safety** — for schema or data migrations: reversibility (`Down` migration correctness), backward
   compatibility during a rolling deployment, backfill correctness, and behaviour under partial failure.
3. **Security** — whether the upgrade fixes or introduces a known vulnerability (cross-check
   `dotnet list package --vulnerable --include-transitive` and NuGet Audit warnings `NU1901`-`NU1904`);
   whether transitive dependencies moved outside policy.
4. **Test evidence** — confirm `dotnet format --verify-no-changes`, `dotnet build -warnaserror`, and
   `dotnet test --collect:"XPlat Code Coverage" --settings coverlet.runsettings` were run against the
   upgraded lock file, and that coverage still meets the configured threshold.
5. **Rollback** — is there a documented path to revert the lock file/version pin if the upgrade regresses
   production; is the change isolated from unrelated refactors.
6. **Governance** — confirm `.ai/dependencies.md` and any ADR are updated when the upgrade changes an
   ongoing standard, per `.ai/tooling-policy.md`.

Flag unpinned or widened version ranges beyond what was justified, silently regenerated lock files without
review, and migrations that skip a stated rollback plan.

## Report

Return severity-ordered findings with the exact file/line or package, the compatibility/data risk, and the
smallest remediation. Do not edit code unless requested.
