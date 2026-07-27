# Required GitHub rulesets and branch protection

Humans must configure these before treating the repository as production-ready.
AI tools must not change GitHub repository settings.

## Protected branches

Protect `main` (and `master` if used):

- Require a pull request before merging
- Require approvals per `docs/approval-matrix.md`
- Dismiss stale reviews on new commits
- Require review from Code Owners (`CODEOWNERS`)
- Require status checks to pass (build, test, security)
- Do not allow force pushes or deletions
- Restrict who can push to the branch

## Rulesets (recommended)

Create an organization or repository ruleset that enforces:

1. Same protected-branch constraints as above
2. Required workflows: build + security scanning
3. Block merges when `SECURITY.md` / ownership files change without technical-owner review
4. Restrict bypass actors to break-glass roles only, with audit

## Required status checks (runnable profiles)

Wire the checks that match `.ai/active-profile.md` verification baseline, including:

- Unit / integration tests
- Coverage gate
- Linting / static analysis
- Dependency vulnerability scan
- Secret scan
- Container scan (when images are built)

## Secrets

Store CI credentials in GitHub Actions secrets or the org secret store — never in Git.
