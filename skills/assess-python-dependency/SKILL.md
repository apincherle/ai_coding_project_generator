---
name: assess-python-dependency
description: Assess a proposed new or replacement Python package/tool against repository dependency and tooling policy before it is added. Use when a feature, refactor, or review surfaces a candidate dependency that is not yet approved in context.
---

# Assess a Python Dependency

## Product context requirement

Before acting, read `.ai/generation.json`, resolve its `projectContextFile`, and read that root product
context file completely. If no generation record exists, locate the single root `<ProjectName>.md` product
context file or ask the user which product context applies. This requirement is in addition to `AGENTS.md`
and the applicable `.ai/*.md` files.

Read and obey `.ai/version-control-policy.md`. Never stage, commit, push, change branches, rewrite history,
or open/merge a pull request.

Read `.ai/tooling-policy.md` and `.ai/dependencies.md` completely before evaluating any candidate. Read
`pyproject.toml` and `uv.lock` to check for an existing capability that already covers the need.

## Required decision sequence

1. Confirm the capability is not already covered by an approved dependency, the standard library, or an
   existing internal utility.
2. If `.ai/dependencies.md` already documents an approved choice for this capability, use it; do not
   silently substitute a preferred alternative.
3. If no choice is documented, present only the smallest credible options with:
   - purpose and why the standard library/existing platform capability is insufficient;
   - maintenance activity, release cadence, and ecosystem maturity;
   - licence and provenance;
   - known CVEs or security posture (cross-check with `pip-audit`'s advisory data where feasible);
   - compatibility with the pinned Python version and existing dependencies;
   - expected `pyproject.toml`/`uv.lock` impact and transitive dependency growth.
4. Ask the user whether the dependency is temporary/task-local or an ongoing project standard.
5. Do not add the dependency to `pyproject.toml` until the user approves it.
6. When approved as an ongoing standard, update `.ai/dependencies.md` (and `.ai/testing.md` or
   `.ai/coding-standards.md` if it changes conventions) in the same change, then add it via `uv add` (or
   `uv add --dev`) so `uv.lock` is regenerated consistently, and update CI/hooks if the dependency
   introduces a new verification step.
7. Record the decision in an ADR when the choice materially affects architecture, security, operations, or
   long-term coupling.

## Prohibited behaviour

- Adding a dependency without context approval.
- Inventing a version, package name, or compatibility claim.
- Adding an overlapping library that duplicates an existing capability without an explicit migration decision.
- Treating a development-only tool as exempt from licence, provenance, or vulnerability review.

## Report

State the assessed capability, the options considered, the recommendation, the approval status obtained
from the user, and the exact files updated (`pyproject.toml`, `uv.lock`, `.ai/dependencies.md`, CI, hooks).
