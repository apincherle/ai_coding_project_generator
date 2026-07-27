---
name: threat-model-dotnet
description: Produce or update a lightweight threat model for a C#/ASP.NET Core service using the repository template. Use before shipping a new trust boundary, external integration, authentication change, or high-risk feature.
---

# Threat Model a .NET Service

## Product context requirement

Before acting, read `.ai/generation.json`, resolve its `projectContextFile`, and read that root product
context file completely. If no generation record exists, locate the single root `<ProjectName>.md` product
context file or ask the user which product context applies. This requirement is in addition to `AGENTS.md`
and the applicable `.ai/*.md` files.

Read and obey `.ai/version-control-policy.md`. Never stage, commit, push, change branches, rewrite history,
or open/merge a pull request.

Read `AGENTS.md`, `.ai/security.md`, `.ai/governance.md`, `.ai/architecture.md`, `.ai/api-guidelines.md`,
`.ai/dependencies.md`, `.ai/business-rules.md` and `.ai/domain-model.md` completely. Read
`docs/threat-model-template.md` and any existing threat model for this service.

## Build the model

Use `docs/threat-model-template.md` sections and populate them for the ASP.NET Core surface under review:

- **Assets** — data classes handled (per `.ai/project-config.yml` `dataClassification`), credentials, tokens.
- **Actors** — end users, upstream services, background jobs, operators.
- **Trust boundaries** — the Kestrel/ASP.NET Core edge, DI-resolved service boundary, persistence boundary,
  any outbound `HttpClient`, and process/container boundary.
- **Abuse cases** — unauthenticated/unauthorized access, model-binding bypass, SSRF from outbound clients,
  insecure deserialization, path/file handling, dependency supply-chain risk (NuGet Audit findings),
  resource exhaustion (unbounded request size/body, unbounded concurrency), secrets in logs or Problem
  Details responses, and CORS misconfiguration.
- **Controls** — model validation returning Problem Details, authn/authz enforcement, `TreatWarningsAsErrors`
  plus analyzers, NuGet Audit/`dotnet list package --vulnerable`, request-size limits, structured logging
  without secrets, container non-root user, and health endpoints that do not leak internal state.
- **Residual risk and owner** — classify per `.ai/governance.md` (low/medium/high) and name the accountable
  owner; high-risk items require a security review before merge.

Demonstrate a credible path from a concrete trigger to impact for each abuse case; do not present
speculation as a finding.

## Report

Write or update the threat model document, list unresolved high-risk items that block merge until a
documented risk owner accepts them, and note any exception that must be recorded under `docs/exceptions/`.
