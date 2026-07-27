# AI Development Standards

**Audience:** developers, reviewers, tech leads  
**Use:** presentation handout and team briefing  
**Companion:** repository `.ai/` files (authoritative)

## Pitch in one sentence

AI accelerates delivery only when people and models share the **same version-controlled rules**, the **same quality gates**, and a **human who owns the merge**.

## Operating model

| Layer | Role | Where it lives |
|---|---|---|
| Context | What is true for this repo | `AGENTS.md`, `.ai/*.md` |
| Skills / prompts | How to do a class of work | `skills/`, `.ai/prompts.md` |
| Gates | Objective enforcement | hooks, CI, analyzers, tests |
| Human | Accountability | review, approve, commit, push |

**Principle:** prompts guide behaviour; hooks and CI enforce rules; a developer remains accountable.

## Non-negotiables

1. Human ownership of every change and approval.
2. No secrets, PII, client data, or proprietary code in unapproved models.
3. Every test has at least one meaningful outcome assertion.
4. Formatting, static analysis, tests, dependency and secret checks must pass.
5. AI output is untrusted until inspected.

## Standard workflow

1. **Orient** — read relevant `.ai/` files and nearby code.
2. **Plan** — acceptance criteria, layers, tests, risk.
3. **Implement** — smallest coherent change.
4. **Inspect** — correctness, security, compatibility, scope.
5. **Validate** — run real checks; record commands and results.
6. **Hand off** — leave changes uncommitted; human stages/commits/pushes.
7. **Approve** — human owns merge after CI.

## Repository as source of truth

```text
AGENTS.md                 # agent entrypoint
.ai/
  project.md              # active stack context
  architecture.md
  coding-standards.md
  api-guidelines.md
  security.md
  testing.md
  governance.md
  tooling-policy.md
  version-control-policy.md
  skills.md / prompts.md
skills/                   # installable procedures
hooks/  .github/  config/
```

Do not copy policy into chat history or skill bodies. Update `.ai/` once; all tools read it.

## Default engineering baseline (Java)

- Java 21, Spring Boot 3.5, Maven, REST/JSON, PostgreSQL
- Thin controllers; services own use cases; repositories isolate persistence
- Constructor injection; DTOs at the boundary; no JPA entities in APIs
- JUnit 5, Mockito, AssertJ, Testcontainers
- Spotless, Checkstyle, PMD, SpotBugs, JaCoCo, OWASP Dependency-Check, Semgrep

Runnable generators also exist for **Python** and **C#**. Other language profiles are standards scaffolds only.

## Test evidence

- Assert values, state, HTTP contracts, or errors — not only mock interactions.
- Mock external boundaries only.
- Prefer the cheapest test that proves the behaviour.
- CI remains authoritative.

## Governance boundaries

- Classify work: low / medium / high risk (see `.ai/governance.md`).
- High-risk work needs domain owner and security review.
- New libraries require `.ai/tooling-policy.md` + human approval.
- AI must never stage, commit, push, or open PRs.

## Adoption checklist

- [ ] Team reads `AGENTS.md` and `.ai/project.md`
- [ ] Hooks configured (`git config core.hooksPath hooks`)
- [ ] `scripts/verify.*` or stack equivalent passes
- [ ] Skills installed for the active language
- [ ] First AI change reviewed with evidence attached to the PR
