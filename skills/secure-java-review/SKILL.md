---
name: secure-java-review
description: Perform a risk-based security review of Java or Spring Boot code, APIs, dependencies, configuration, database access, authentication, authorization, or AI-generated changes. Use when Codex is asked for a security assessment governed by repository Markdown context.
---

# Secure Java Review

## Product context requirement

Before acting, read `.ai/generation.json`, resolve its `projectContextFile`, and read that root product
context file completely. If no generation record exists, locate the single root `<ProjectName>.md` product
context file or ask the user which product context applies. This requirement is in addition to `AGENTS.md`
and the applicable `.ai/*.md` files.

Read and obey `.ai/version-control-policy.md`. Use Git read-only; never stage, commit, push, change branches,
rewrite history, or open/merge a pull request.

## Load security context

Locate the repository root. Read `AGENTS.md`, `.ai/security.md`, `.ai/governance.md`,
`.ai/project.md`, `.ai/architecture.md`, `.ai/api-guidelines.md`, `.ai/dependencies.md`,
and relevant business/domain files completely. Inspect the actual code, configuration, dependencies,
deployment artifacts, tests, and trust boundaries.

Apply `.ai/tooling-policy.md` to dependency provenance. Flag undeclared, unapproved, duplicate or silently
substituted libraries/tools and missing context, manifest, lock/version or CI updates.

## Review

1. Classify assets, actors, entry points, data sensitivity, and trust boundaries.
2. Check authentication, authorization at every protected action, tenancy, and least privilege.
3. Check validation, injection, deserialization, SSRF, file/path handling, redirects, and output encoding.
4. Check secrets, logs, error leakage, environment configuration, and production defaults.
5. Check dependency provenance, known-risk patterns, unsafe cryptography, and supply-chain controls.
6. Check database queries, transactions, mass assignment, concurrency, and data retention.
7. Check abuse cases, rate limits, resource exhaustion, and operational detection.
8. Inspect tests for meaningful security outcomes; mock verification alone is insufficient.

Do not report speculative vulnerabilities as facts. Demonstrate a credible path from input to impact.
Do not expose secrets or provide exploit detail beyond what remediation requires.

## Output

Order findings by severity. Include affected file/line, preconditions, attack or failure path, impact,
evidence, and remediation. Identify required security owners and any high-risk ambiguity that blocks approval.
State coverage gaps and tools/checks run.
