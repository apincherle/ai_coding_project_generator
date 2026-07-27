---
name: review-python-change
description: Review Python or FastAPI changes for correctness, typing, architecture, security, compatibility, maintainability and test quality. Use for diffs, pull requests or AI-generated Python code governed by AGENTS.md and .ai Markdown context.
---

# Review a Python Change

Read and obey `.ai/version-control-policy.md`. Use Git read-only; never stage, commit, push, change branches,
rewrite history, or open/merge a pull request.

Read `AGENTS.md` and all applicable `.ai/*.md` files completely. Inspect changed and surrounding code,
tests, `pyproject.toml`, migrations and relevant ADRs.

Read `.ai/tooling-policy.md`. Flag packages/tools absent from active context, lacking approval evidence,
duplicating an existing capability, or missing `pyproject.toml`, lockfile, CI and context updates.

Review in this order: business correctness and data loss; authentication/authorization and input safety;
API/schema compatibility; async/blocking and transaction behaviour; typing and exception handling;
test outcomes; dependency/provenance risk; maintainability and observability.

Flag `Any`, non-strict/unvalidated Pydantic boundaries, broad catches, mutable globals, service locators, unsafe deserialization, blocking work in async
paths, generic helpers, excessive internal mocking and tests without meaningful assertions.

Return severity-ordered findings with exact file/line, failure scenario, impact and smallest remediation.
Do not edit code unless requested.
