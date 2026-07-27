# Using Reusable Development Skills

**Audience:** developers using Codex / Cursor-style skill folders  
**Companion:** `.ai/skills.md` (authoritative skill index)

## What a skill is

A skill is a **version-controlled procedure** (`skills/<name>/SKILL.md`) that tells an assistant how to perform a class of work. Project facts stay in `.ai/`; the skill loads them every time.

| Layer | Responsibility | Example |
|---|---|---|
| Project context | What is true here | `.ai/architecture.md` |
| Skill | How to do the work | `create-spring-feature` |
| Request | What you need now | “Add customer search by email” |
| Gates | Objective proof | `mvn verify` / `pytest` / `dotnet test` |
| Human | Accountability | inspect, commit, merge |

## Inventory (14 skills)

### Java / Spring Boot (6)

| Skill | Use when |
|---|---|
| `create-spring-feature` | New endpoint, service, repository, DTO, migration |
| `generate-java-tests` | JUnit 5 / AssertJ / Mockito / Testcontainers coverage |
| `review-java-change` | Diff or PR review against `.ai/` standards |
| `diagnose-java-failure` | Build, test, CI, runtime root-cause analysis |
| `refactor-java-code` | Behaviour-preserving cleanup |
| `secure-java-review` | Security-focused review |

### Python (4)

| Skill | Use when |
|---|---|
| `create-python-feature` | FastAPI / typed Python feature work |
| `generate-python-tests` | pytest coverage with real assertions |
| `review-python-change` | Python change review |
| `secure-python-review` | Python security review |

### C# / .NET (4)

| Skill | Use when |
|---|---|
| `create-dotnet-feature` | ASP.NET Core / .NET feature work |
| `generate-dotnet-tests` | xUnit / FluentAssertions coverage |
| `review-dotnet-change` | .NET change review |
| `secure-dotnet-review` | .NET security review |

Scaffold profiles (C, C++, Rust, Scala, Node, React, Next.js) have no bundled skills yet — use `.ai/prompts.md`.

## Install and invoke

1. Copy each needed folder from `skills/` into the tool’s skills directory, or use your org distribution.
2. Work inside the target repository so the skill can find `AGENTS.md`.
3. Invoke by name:

```text
Use $create-spring-feature to add GET /api/v1/customers/search?email={email}.
Return 404 when absent, validate email, update OpenAPI,
add unit and integration tests, and do not add dependencies.
```

## Writing effective requests

- Name the **outcome** and **acceptance criteria**.
- State scope limits (no API break, no new dependency, diagnose only).
- Ask for **evidence**: commands run, results, changed files, residual risk.
- Do not paste entire standards — they already live in `.ai/`.

## Expected handoff (every skill)

- Uncommitted working tree (AI must not commit or push)
- Changed files list
- Validation evidence
- Assumptions and residual risk
- Optional commit-message suggestion for a human

## Demo script (Java)

1. `Use $create-spring-feature to add …`
2. `Use $generate-java-tests to cover failure paths …`
3. `Use $review-java-change to review the current changes …`
4. Human inspects, stages, commits, opens PR
5. CI must pass before merge

## Governance reminders

- Read `.ai/tooling-policy.md` before adding libraries.
- Read `.ai/version-control-policy.md` — human-only Git publication.
- Security findings block merge unless a risk owner accepts them.
