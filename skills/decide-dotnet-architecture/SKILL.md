---
name: decide-dotnet-architecture
description: Facilitate and document an architecture decision for a C#/ASP.NET Core service (layering, boundaries, persistence strategy, messaging, or a similar structural choice). Use when a change has meaningful trade-offs rather than one obvious implementation.
---

# Decide .NET Architecture

## Product context requirement

Before acting, read `.ai/generation.json`, resolve its `projectContextFile`, and read that root product
context file completely. If no generation record exists, locate the single root `<ProjectName>.md` product
context file or ask the user which product context applies. This requirement is in addition to `AGENTS.md`
and the applicable `.ai/*.md` files.

Read and obey `.ai/version-control-policy.md`. Never stage, commit, push, change branches, rewrite history,
or open/merge a pull request.

Read `AGENTS.md`, `.ai/project.md`, `.ai/architecture.md`, `.ai/coding-standards.md`, `.ai/api-guidelines.md`,
`.ai/security.md`, `.ai/dependencies.md`, `.ai/tooling-policy.md`, `.ai/business-rules.md` and
`.ai/domain-model.md` completely. Read `docs/adr/0000-template.md` and existing ADRs.

## Decision process

1. Restate the problem, the forces in tension (e.g. simplicity vs. extensibility, latency vs. consistency,
   coupling vs. duplication), and the constraints from `.ai/architecture.md` (layered structure: endpoints ->
   application services -> persistence ports/adapters; dependencies point inward).
2. Enumerate a small number of credible options; avoid speculative or over-engineered designs.
3. Evaluate each option against: testability without excessive substitution, boundary clarity, operational
   cost, compatibility with the approved package set, and alignment with `.ai/business-rules.md`/domain model.
4. State which option keeps endpoints/controllers thin, keeps business rules out of static/global state, and
   preserves nullable-reference safety and `TreatWarningsAsErrors`.
5. Recommend one option with explicit trade-offs and risks; do not present a decision as risk-free.
6. Stop and ask the user when the decision materially changes the public API, data model, or introduces a
   new dependency not covered by `.ai/dependencies.md`.

## Record the decision

Write or update an ADR under `docs/adr/` following `docs/adr/0000-template.md`, capturing context, decision,
consequences, and alternatives considered. Update `.ai/architecture.md` only when the decision changes an
ongoing structural convention, and only after the user approves it as a standard.

## Report

Summarize the decision, the ADR file written/updated, residual risks, and any follow-up implementation work
required (which should go through `create-dotnet-feature`, `refactor-dotnet-code`, or a dedicated task).
