---
name: review-dotnet-change
description: Review C# or ASP.NET Core changes for correctness, nullable safety, architecture, security, compatibility, maintainability and test quality. Use for diffs, pull requests or AI-generated .NET code governed by AGENTS.md and .ai Markdown context.
---

# Review a .NET Change

Read and obey `.ai/version-control-policy.md`. Use Git read-only; never stage, commit, push, change branches,
rewrite history, or open/merge a pull request.

Read `AGENTS.md` and all applicable `.ai/*.md` files completely. Inspect changed and surrounding code,
tests, project files, migrations and relevant ADRs.

Read `.ai/tooling-policy.md`. Flag packages/tools absent from active context, lacking approval evidence,
duplicating an existing capability, or missing project/central package, lockfile, CI and context updates.

Review in this order: business correctness and data loss; authentication/authorization; API/schema compatibility;
async/cancellation, transactions and DI lifetimes; nullable safety and error handling; test outcomes;
NuGet/provenance risk; maintainability and observability.

Flag sync-over-async, missing cancellation, incorrect service lifetimes, hidden static state, over-abstraction,
generic helpers, excessive substitutions and tests without meaningful assertions.

Return severity-ordered findings with exact file/line, failure scenario, impact and smallest remediation.
Do not edit code unless requested.
