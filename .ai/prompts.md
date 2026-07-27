# Prompt Library

Presentation-ready prompt outlines and demos for AI-assisted work.
Named installable skills in `skills/` (see `.ai/skills.md`) take precedence for Java, Python and C#.
Use these prompts when no skill exists, or when demonstrating the operating model to a team.

## Presentation demo arc

Use this sequence in a live walkthrough:

1. Orient — “Read `AGENTS.md` and `.ai/project.md`. Summarise the stack, gates and human-only Git rule.”
2. Implement — invoke `$create-spring-feature` / `$create-python-feature` / `$create-dotnet-feature` (or the feature prompt below).
3. Test — invoke the matching generate-*-tests skill (or the test prompt below).
4. Review — invoke the matching review-*-change skill.
5. Hand off — AI leaves changes uncommitted; a human stages, commits and opens the PR.

Ask the audience to notice: context lives in Git, skills load it, gates prove it, humans publish it.

## Implement a feature

```text
Read AGENTS.md and the relevant .ai standards (project, architecture, coding,
API, security, testing, business rules, domain model, dependencies, tooling-policy).
Restate acceptance criteria, assumptions, scope and risk.
Propose the smallest coherent design.
Implement: <objective>.
Add tests with at least one meaningful outcome assertion per test.
Run the active verification baseline and report commands, results, changed files,
assumptions and residual risk.
Do not stage, commit or push.
```

## Generate tests

```text
Read .ai/testing.md and inspect <type or module>.
Identify observable behaviours and boundaries.
Add positive, negative and edge-case tests.
Mock only external collaborators.
Every test must assert a value, state, HTTP contract or error — not only interactions.
Run the targeted tests and report gaps.
Do not stage, commit or push.
```

## Review a pull request or diff

```text
Read governance and all applicable .ai standards.
Inspect the current diff and tests.
Prioritise correctness, security, data loss, concurrency, API compatibility and
missing behavioural assertions.
Cite exact files and lines.
Separate blockers from suggestions.
Do not edit files unless asked. Do not stage, commit or push.
```

## Diagnose a failure

```text
Reproduce first. Record the exact symptom and narrowest reproduction.
Distinguish symptom from root cause. Show evidence for ranked hypotheses.
Do not change code unless asked.
If a fix is requested, propose the smallest safe change plus a regression test,
leave it uncommitted, and report validation evidence.
```

## Secure review

```text
Read .ai/security.md and .ai/governance.md.
Review trust boundaries, data classification, authn/authz, injection, SSRF,
secrets, logging, dependencies and abuse cases.
Order findings by severity with credible impact.
Stop and escalate on high-risk ambiguity.
```

## Select a library or tool

```text
Read .ai/tooling-policy.md, .ai/dependencies.md and the active language context.
If an approved choice exists, use it.
If none exists, do not add a dependency. Summarise need, alternatives,
licence/provenance, security, compatibility and maintenance cost, then ask me
to approve a specific option and whether it is task-local or an ongoing standard.
If ongoing, update .ai context, manifest/lockfile, CI and hooks in the same change.
```

## Human version-control handoff

```text
Read .ai/version-control-policy.md.
Leave all changes in the working tree.
Report changed files, validation evidence, risks and an optional commit-message suggestion.
A human must inspect, stage, commit, push and open the pull request.
```

## Generate a product repo (operator prompt)

```text
Do not clone the full starter-kit catalogue for product work.
Run scripts/create-project.ps1 with the chosen profile and destination.
Then replace Customer-example business rules and domain model, confirm
verification runs, and install matching skills.
```

## Scaffold-profile note

For C, C++, Rust, Scala, Node, React and Next.js profiles, only standards context
is generated today. Use the prompts above until stack-specific skills exist.
