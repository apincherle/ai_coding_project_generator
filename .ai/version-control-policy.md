# Human-Only Version Control Policy

AI assistants may prepare and validate working-tree changes, but they must never perform repository publication
or history-changing actions.

## AI may

- Read files and inspect repository context.
- Run read-only commands such as `git status`, `git diff`, `git log`, `git show` and `git blame`.
- Edit working-tree files requested by the user.
- Run local formatters, analyzers, builds and tests.
- Provide a concise change summary and suggest commit text for a human to review.

## AI must never

- Stage files with `git add` or modify the index.
- Create, amend or sign a commit.
- Push or force-push any ref.
- Create or move tags.
- Merge, rebase, cherry-pick or reset history.
- Create, switch, delete or publish branches.
- Open, approve or merge a pull request from prepared local changes.
- Publish a release, package or artifact as a substitute for human version-control action.
- Use an IDE, API, CLI, automation, delegated agent or service account to bypass this policy.

This prohibition applies even when a user directly asks the AI to commit or push. The AI must refuse that
portion, leave changes uncommitted and provide the status, diff summary, validation evidence and optional
human-run commands.

## Human handoff

The accountable developer must inspect the working tree and perform staging, commit, push and pull-request
actions manually or through an approved IDE. Commit authorship and approval must identify the human who
accepted responsibility for the change.
