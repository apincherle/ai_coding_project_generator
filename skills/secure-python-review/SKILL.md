---
name: secure-python-review
description: Perform a risk-based security review of Python or FastAPI code, APIs, configuration, dependencies, database access, authentication or AI-generated changes. Use when repository Markdown security and governance controls apply.
---

# Secure Python Review

Read and obey `.ai/version-control-policy.md`. Use Git read-only; never stage, commit, push, change branches,
rewrite history, or open/merge a pull request.

Read `AGENTS.md`, `.ai/security.md`, `.ai/governance.md`, `.ai/project.md`,
`.ai/architecture.md`, `.ai/api-guidelines.md`, `.ai/dependencies.md` and domain guidance completely.

Apply `.ai/tooling-policy.md` to package and tool provenance. Flag undeclared, unapproved, duplicate or
silently substituted packages and missing context, lockfile or verification updates.

Map assets, actors, entry points and trust boundaries. Check authentication, authorization, tenancy,
Pydantic/input validation, injection, SSRF, path/file handling, deserialization, templates/output encoding,
secrets, logs, exception leakage, CORS, dependency provenance and resource exhaustion.
Assess unexpected-field handling, settings validation, mutable global state, async blocking and background-task authority.

Demonstrate a credible path from input to impact; do not present speculation as fact.
Return severity-ordered findings with preconditions, evidence, impact, remediation, owners and coverage gaps.
