---
name: secure-dotnet-review
description: Perform a risk-based security review of C# or ASP.NET Core code, APIs, configuration, NuGet dependencies, EF Core access, authentication or AI-generated changes. Use when repository Markdown security and governance controls apply.
---

# Secure .NET Review

Read and obey `.ai/version-control-policy.md`. Use Git read-only; never stage, commit, push, change branches,
rewrite history, or open/merge a pull request.

Read `AGENTS.md`, `.ai/security.md`, `.ai/governance.md`, `.ai/project.md`,
`.ai/architecture.md`, `.ai/api-guidelines.md`, `.ai/dependencies.md` and domain guidance completely.

Apply `.ai/tooling-policy.md` to NuGet and tool provenance. Flag undeclared, unapproved, duplicate or silently
substituted packages/tools and missing context, lockfile or verification updates.

Map assets, actors, endpoints and trust boundaries. Check authentication, authorization, tenancy,
model validation, mass assignment, injection, SSRF, file/path handling, deserialization, antiforgery,
secrets, Data Protection, logs, exception leakage, CORS, dependency provenance and resource exhaustion.
Review EF Core query safety and DI/background-service authority.

Demonstrate a credible path from input to impact. Return severity-ordered findings with preconditions,
evidence, impact, remediation, owners and coverage gaps.
