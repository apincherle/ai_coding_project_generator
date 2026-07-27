---
name: review-python-migration
description: Review a Python dependency major-version upgrade, runtime/interpreter upgrade, framework migration, or data/schema migration for compatibility, data safety, and rollback. Use for upgrade PRs or migration scripts under repository Markdown standards.
---

# Review a Python Migration

## Product context requirement

Before acting, read `.ai/generation.json`, resolve its `projectContextFile`, and read that root product
context file completely. If no generation record exists, locate the single root `<ProjectName>.md` product
context file or ask the user which product context applies. This requirement is in addition to `AGENTS.md`
and the applicable `.ai/*.md` files.

Read and obey `.ai/version-control-policy.md`. Use Git read-only; never stage, commit, push, change branches,
rewrite history, or open/merge a pull request.

Read `AGENTS.md`, `.ai/dependencies.md`, `.ai/tooling-policy.md`, `.ai/testing.md`, `.ai/security.md`, and
`.ai/architecture.md` completely. Inspect the migration diff, `pyproject.toml`, `uv.lock`, changelog/release
notes for the upgraded component, and any data/schema migration scripts.

## Review order

1. **Compatibility** — breaking API/behaviour changes in the upgraded interpreter, framework, or library;
   deprecated features still relied on; Pydantic v1→v2-style breaking changes if applicable.
2. **Data safety** — for schema or data migrations: reversibility, backward compatibility during rollout,
   backfill correctness, and behaviour under partial failure.
3. **Security** — whether the upgrade fixes or introduces a known vulnerability (cross-check
   `uv run pip-audit --local --skip-editable`); whether transitive dependencies moved outside policy.
4. **Test evidence** — confirm `uv run pytest`, `uv run mypy src`, `uv run ruff check .`, and
   `uv run lint-imports` were run against the upgraded lockfile, and that coverage still meets the
   `fail_under` gate.
5. **Rollback** — is there a documented path to revert the lockfile/version pin if the upgrade regresses
   production; is the change isolated from unrelated refactors.
6. **Governance** — confirm `.ai/dependencies.md` and any ADR are updated when the upgrade changes an
   ongoing standard, per `.ai/tooling-policy.md`.

Flag unpinned or widened version ranges beyond what was justified, silently regenerated lockfiles without
review, and migrations that skip a stated rollback plan.

## Report

Return severity-ordered findings with the exact file/line or dependency, the compatibility/data risk, and
the smallest remediation. Do not edit code unless requested.
