---
name: governance-review
description: Review a change, repository, or generated project against AI governance, ownership, risk classification, and approval-matrix requirements. Use for periodic governance audits or before merging changes classified as medium/high risk.
---

# Governance Review

## Product context requirement

Before acting, read `.ai/generation.json`, resolve its `projectContextFile`, and read that root product
context file completely. If no generation record exists, locate the single root `<ProjectName>.md` product
context file or ask the user which product context applies. This requirement is in addition to `AGENTS.md`
and the applicable `.ai/*.md` files.

Read and obey `.ai/version-control-policy.md`. Use Git read-only; never stage, commit, push, change branches,
rewrite history, or open/merge a pull request.

Read `AGENTS.md`, `.ai/governance.md`, `.ai/security.md`, `.ai/dependencies.md`, `.ai/tooling-policy.md`,
`CODEOWNERS`, `SECURITY.md`, `docs/approval-matrix.md`, `docs/github-rulesets.md`, and
`docs/exceptions/*.md` (excluding `template.md`) completely.

## Review

1. **Risk classification** — confirm the change is classified low/medium/high per `.ai/governance.md`
   (authentication, authorization, cryptography, money, safety, regulated data, or production operations
   changes are high risk) and that high-risk work has a named domain owner and a security review recorded.
2. **Ownership** — confirm `CODEOWNERS` covers the changed paths and matches `.ai/project-config.yml`
   `owners.technical`/`owners.business`.
3. **Approval matrix** — confirm the change type maps to the correct approver tier in
   `docs/approval-matrix.md`.
4. **Exceptions** — for any exception under `docs/exceptions/`, confirm it has a rule/gate id, requester,
   approver, opened/expiry dates, linked risk classification, justification, compensating controls, and
   removal plan, and is not expired (`scripts/check-exceptions.ps1` can be run for a fast check).
5. **AI usage disclosure** — confirm the PR description records the model/tool used, purpose, human owner,
   changed files, validation evidence, and that AI did not approve its own output.
6. **Dependency governance** — confirm any new/changed dependency is documented in `.ai/dependencies.md`
   with approval evidence, per `.ai/tooling-policy.md`.
7. **Secret handling** — confirm no credentials, tokens, PII, client data, or production logs appear in the
   change, prompts, or committed files.

## Report

Return a pass/fail table per governance area with the exact gap, the required remediation, and who must
close it (technical owner, business owner, or security reviewer) before merge is safe.
