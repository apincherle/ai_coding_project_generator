---
name: review-java-change
description: Review a Java or Spring Boot change, diff, pull request, or generated code for correctness, architecture, security, compatibility, maintainability, and test quality. Use when Codex must assess code against repository AGENTS.md and .ai Markdown standards without implementing fixes unless asked.
---

# Review a Java Change

## Product context requirement

Before acting, read `.ai/generation.json`, resolve its `projectContextFile`, and read that root product
context file completely. If no generation record exists, locate the single root `<ProjectName>.md` product
context file or ask the user which product context applies. This requirement is in addition to `AGENTS.md`
and the applicable `.ai/*.md` files.

Read and obey `.ai/version-control-policy.md`. Use Git read-only; never stage, commit, push, change branches,
rewrite history, or open/merge a pull request.

## Establish the contract

Locate the repository root. Read `AGENTS.md` and all applicable `.ai/*.md` files completely,
especially architecture, coding, API, security, testing, governance, business rules, and domain model.
Read the changed files, surrounding code, tests, build configuration, migrations, and relevant ADRs.

Read `.ai/tooling-policy.md`. Flag every new or replaced library/tool that is not documented in active
context, lacks approval evidence, duplicates an existing capability, or omits required manifest, lock/version,
CI or context updates.

## Review in priority order

1. Requirements, business correctness, data loss, concurrency, and error paths.
2. Authentication, authorization, validation, injection, secrets, logging, and unsafe dependencies.
3. Public API, schema, serialization, and backward compatibility.
4. Architectural boundaries and Spring lifecycle/transaction behaviour.
5. Abstraction quality: interfaces represent genuine boundaries; collaborators have cohesive responsibilities; generic helpers, pass-through wrappers, static state, and unnecessary mock seams are avoided.
6. Test coverage and quality; flag every test with no meaningful outcome assertion and excessive internal mocking that signals unclear responsibilities.
7. Maintainability, duplication, naming, observability, and documentation.

Verify claims against code. Do not infer safety from the author's summary or from passing tests alone.

## Output

Lead with actionable findings ordered by severity. For each finding provide:

- severity and concise title;
- exact file and tight line range;
- failure scenario and impact;
- repository rule or behaviour violated;
- smallest credible remediation.

Separate blockers from non-blocking suggestions. State explicitly when no actionable findings remain and list validation gaps.
Do not edit code unless the user also requests fixes.
