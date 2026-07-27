---
name: production-readiness-assessment
description: Assess whether a generated service is ready for production traffic - health/readiness, graceful shutdown, observability, coverage/security gates, dependency locking, SBOM, and rollback. Use before a first production release or a production-readiness review.
---

# Production Readiness Assessment

## Product context requirement

Before acting, read `.ai/generation.json`, resolve its `projectContextFile`, and read that root product
context file completely. If no generation record exists, locate the single root `<ProjectName>.md` product
context file or ask the user which product context applies. This requirement is in addition to `AGENTS.md`
and the applicable `.ai/*.md` files.

Read and obey `.ai/version-control-policy.md`. Use Git read-only; never stage, commit, push, change branches,
rewrite history, or open/merge a pull request.

Read `AGENTS.md`, `.ai/project.md`, `.ai/architecture.md`, `.ai/security.md`, `.ai/dependencies.md`,
`.ai/testing.md`, `.ai/project-config.yml` (for `productionCriticality` and `deploymentTarget`), and the
active `.github/workflows/*.yml`.

## Checklist

1. **Health/readiness** — liveness and readiness endpoints exist, do not leak internal state, and are wired
   into the container `HEALTHCHECK` (Java `/actuator/health/liveness`, Python `/health`/`/ready`, .NET health
   endpoints).
2. **Graceful shutdown** — the process handles termination signals, drains in-flight requests, and closes
   connections/resources within a bounded timeout.
3. **Observability** — structured logging without secrets, a correlation/request id propagated across the
   request lifecycle, and metrics/tracing hooks appropriate to the stack.
4. **Quality gates** — the coverage threshold (JaCoCo `jacoco.line.coverage`, pytest `fail_under`, or
   coverlet `Threshold`) is enforced in CI, not just locally; static analysis/architecture checks (ArchUnit,
   import-linter, .NET analyzers) run in CI.
5. **Dependency supply chain** — a committed lock file (`uv.lock`, `packages.lock.json`, Maven
   dependency-check profile) pins direct and transitive dependencies; `pip-audit`/NuGet Audit/OWASP
   dependency-check run in CI or hooks; an SBOM can be produced (CycloneDX) even if not yet automated.
6. **Secrets and configuration** — no secrets in source or images; configuration is externalized and
   validated at startup; `.env`/secrets are excluded from Git and from the built image.
7. **Container hardening** — non-root user, minimal base image, pinned base image tags, and a `HEALTHCHECK`
   instruction.
8. **Rollback** — a documented rollback path (previous image tag, migration `Down` script, feature flag) and
   a named on-call/technical owner from `.ai/project-config.yml`.
9. **Governance** — `docs/approval-matrix.md` sign-off obtained for `productionCriticality`, and no expired
   exception under `docs/exceptions/` (`scripts/check-exceptions.ps1`).

## Report

Return a pass/fail table per checklist item, current evidence, the smallest remediation for each gap, and
an overall go/no-go recommendation with the residual risks a human owner must accept before release.
