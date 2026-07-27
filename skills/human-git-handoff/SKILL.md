---
name: human-git-handoff
description: Prepare a clean human handoff of AI-prepared working-tree changes - summarize the diff, suggest a commit message and PR description, and confirm nothing was staged, committed, or pushed. Use at the end of an AI-assisted change before a human takes over Git actions.
---

# Human Git Handoff

## Product context requirement

Before acting, read `.ai/generation.json`, resolve its `projectContextFile`, and read that root product
context file completely if available; otherwise proceed using `AGENTS.md` and the applicable `.ai/*.md`
files alone, since this skill is Git-state-focused and may run outside a generated project.

Read and obey `.ai/version-control-policy.md` in full before doing anything else in this skill.

## Mandatory boundary

This skill must never stage, commit, amend, tag, push, force-push, change branches, rewrite history, open a
pull request, approve, merge, or publish repository changes, even when explicitly asked. Refuse that portion
of any request and explain that a human must perform it manually or through an approved IDE.

## Prepare the handoff

1. Run only read-only Git commands: `git status`, `git diff`, `git diff --staged`, `git log`, `git show`,
   `git blame` as needed to understand the current working-tree state.
2. Confirm nothing is staged that should not be (e.g. secrets, `.env`, credentials, large generated
   artifacts, `.venv`/`node_modules`/`bin`/`obj`/`target` build output).
3. Summarize the change set: files added/modified/deleted, the functional intent, and any follow-up work
   left undone.
4. Draft a concise commit message (why over what) consistent with the repository's existing commit style
   (inspect recent `git log` messages for tone and format).
5. Draft a short PR description including: summary, test plan/validation evidence actually run, AI usage
   disclosure (model/tool, purpose, human owner) per `.ai/governance.md` if applicable, and any risk or
   exception that needs reviewer attention.
6. List the exact human-run commands needed next (e.g. `git add <paths>`, `git commit -m "..."`,
   `git push`, opening the PR), without executing any of them.

## Report

Present the diff summary, suggested commit message, suggested PR description, and the explicit list of
manual Git commands for the accountable human to run. State clearly that staging, committing, and pushing
were intentionally not performed.
