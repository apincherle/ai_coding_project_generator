# AI Engineering Starter Kit

A production-oriented baseline for consistent, secure AI-assisted Java development.
The repository is the durable context: people and AI tools read the same version-controlled rules.

## Quick start

1. Read `AGENTS.md` and `.ai/project.md`.
2. Install Java 21, Maven 3.9+, Docker, and Git.
3. Run `git config core.hooksPath hooks`.
4. Run `./scripts/verify.sh` (or `scripts\verify.ps1` on Windows).
5. Open `examples/spring-api` and run `mvn verify`.

## Non-negotiable gates

- Human ownership of every change and approval.
- No secrets, personal data, client data, or proprietary code in unapproved models.
- Every test contains at least one outcome assertion; interaction verification alone is insufficient.
- Formatting, static analysis, tests, dependency checks, secret scanning, and CI must pass.
- AI output is untrusted until inspected.

See `docs/onboarding/GETTING_STARTED.md` and `.ai/skills.md`.

## Starting a new repository

Read `docs/QUICKSTART.md` before using this kit as a project template. It explains what to rename,
replace, retain or delete and how to activate backend, native, Node.js, React or Next.js context profiles.

For normal use, generate a minimal repository rather than cloning this entire catalogue:

```powershell
scripts\create-project.ps1 -Profile java -ProjectName customer-service -Destination C:\Workspace\customer-service
```

## Reusable development skills

The `skills/` directory contains six complete Codex skills for feature development, test generation,
code review, diagnosis, refactoring, and security review. Every skill loads the repository's Markdown
context before working. See `.ai/skills.md` for installation and invocation examples.
