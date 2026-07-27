---
name: threat-model-python
description: Produce or update a lightweight threat model for a Python/FastAPI service using the repository template. Use before shipping a new trust boundary, external integration, authentication change, or high-risk feature.
---

# Threat Model a Python Service

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

Use `docs/threat-model-template.md` sections and populate them for the Python/FastAPI surface under review:

- **Assets** — data classes handled (per `.ai/project-config.yml` `dataClassification`), credentials, tokens.
- **Actors** — end users, upstream services, background jobs, operators.
- **Trust boundaries** — the ASGI edge, FastAPI dependency-injection boundary, persistence boundary, any
  outbound HTTP client, and process/container boundary.
- **Abuse cases** — unauthenticated/unauthorized access, injection via Pydantic-bypassing inputs, SSRF from
  outbound clients, unsafe deserialization (`pickle`, unsafe `yaml.load`), path/file handling, dependency
  supply-chain risk, resource exhaustion (unbounded request size/body, unbounded concurrency), secrets in
  logs or error responses, and CORS misconfiguration.
- **Controls** — Pydantic `extra="forbid"` boundary models, authn/authz enforcement, `import-linter`
  boundary enforcement, `pip-audit`/dependency pinning, request-size limits, structured logging without
  secrets, container non-root user, and health/readiness endpoints that do not leak internal state.
- **Residual risk and owner** — classify per `.ai/governance.md` (low/medium/high) and name the accountable
  owner; high-risk items require a security review before merge.

Demonstrate a credible path from a concrete trigger to impact for each abuse case; do not present
speculation as a finding.

## Report

Write or update the threat model document, list unresolved high-risk items that block merge until a
documented risk owner accepts them, and note any exception that must be recorded under `docs/exceptions/`.
