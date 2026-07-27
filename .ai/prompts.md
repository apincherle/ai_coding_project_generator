# Prompt Library

## Implement a feature
Read all `.ai` standards. Restate acceptance criteria and risks. Propose the smallest design. Implement with
tests containing real assertions. Run relevant checks. Summarise changed files, evidence, and residual risk.

## Review a pull request
Inspect the diff and tests. Prioritise correctness, security, data loss, concurrency, API compatibility, and
missing behavioural assertions. Cite exact files and lines. Separate blockers from suggestions.

## Diagnose a failure
Reproduce first. Distinguish symptom from root cause. Do not change code unless asked. Show evidence, likely
cause, and the smallest safe fix with a regression test.

## Select a library or tool

Read `.ai/tooling-policy.md`, `.ai/dependencies.md`, the active language context and existing manifests/lockfiles.
If the capability already has an approved choice, use it. If no choice is documented, do not add a dependency.
Ask the user to approve a specific option after summarising need, alternatives, licence/provenance, security,
compatibility and maintenance cost. Ask whether the selection is task-local or an ongoing project standard.
When approved as ongoing, update the applicable `.ai` context, dependency manifest, lockfile, CI and hooks.

## Human version-control handoff

Do not stage, commit or push. Read `.ai/version-control-policy.md`, leave all changes in the working tree and
report changed files, validation evidence, risks and an optional commit-message suggestion. A human must inspect,
stage, commit, push and open the pull request manually or through an approved IDE.
