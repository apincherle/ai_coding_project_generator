---
name: check-context-completeness
description: Audit whether a repository's AI context (AGENTS.md, .ai/*.md, entrypoints, generation.json, skills) is present, internally consistent, and free of placeholders. Use before relying on AI-assisted workflows in a project, or periodically as a governance check.
---

# Check Context Completeness

## Product context requirement

Before acting, read `.ai/generation.json` if present to resolve `projectContextFile`, `profile`, and
`maturity`. If no generation record exists, locate the single root `<ProjectName>.md` product context file
or ask the user which product context applies. This skill exists specifically to detect when that discovery
step fails, so report clearly when context cannot be located rather than guessing.

Read and obey `.ai/version-control-policy.md`. Use Git read-only; never stage, commit, push, change branches,
rewrite history, or open/merge a pull request.

## Checks

1. **Root entrypoints** — `AGENTS.md`, `CLAUDE.md`, `.github/copilot-instructions.md`, and
   `.cursor/rules/standards.mdc` all exist and reference `AGENTS.md` and the resolved product context file.
2. **Required `.ai/*.md` files** — `project.md`, `architecture.md`, `coding-standards.md`, `testing.md`,
   `security.md`, `governance.md`, `dependencies.md`, `tooling-policy.md`, `version-control-policy.md`,
   `skills.md`, `prompts.md` exist and contain no forbidden placeholder (`TODO`, `changeme`, `REPLACE_ME`,
   `example.com`) unless explicitly marked as an open decision.
3. **Product identity** — `.ai/project-config.yml` matches `.ai/project-config.schema.yml`: all required
   keys present, owners non-blank, classifications from the allowed enums, and identity blocks for the
   active stack populated with no sample/placeholder values left over from the template.
4. **Skill wiring** — every skill referenced in `.ai/skills.md` actually exists under `skills/` and its
   `SKILL.md` requires reading `.ai/generation.json`/product context, `AGENTS.md`, and
   `.ai/version-control-policy.md`.
5. **Governance artifacts** — `CODEOWNERS`, `SECURITY.md`, `docs/support.md`, `docs/approval-matrix.md`,
   `docs/github-rulesets.md`, `docs/exceptions/template.md` exist and reference the correct owners.
6. **Runnable enforcement** (when `maturity: runnable`) — hooks, `scripts/install-hooks.*`,
   `.github/workflows/security.yml`, `config/semgrep.yml`, and `scripts/check-exceptions.ps1` are present.
7. **Drift** — the AI context's stated verification command in `.ai/active-profile.md` or `manifests/profiles.json`
   still matches the actual build/test tooling in the repository (lockfiles, CI workflow steps).

## Report

Return a pass/fail table per check with the exact missing file, placeholder, or inconsistency, ordered by
governance impact (missing version-control policy or security context first). Do not edit files unless the
user explicitly asks for the gaps to be fixed, and even then leave changes uncommitted.
