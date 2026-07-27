# Repository Instructions for AI Agents

Before changing code, read `.ai/project.md`, `.ai/architecture.md`,
`.ai/coding-standards.md`, `.ai/security.md`, and `.ai/testing.md`.

Make the smallest coherent change. Never weaken quality gates, delete tests to make a build pass,
invent requirements, expose secrets, or change a public API without calling it out.
Run the closest relevant checks, report what ran, and identify anything not verified.
All generated tests require at least one meaningful state or value assertion.

For work inside a nested application or package, locate and read the nearest applicable `AGENTS.md` and
`.ai` context in addition to the repository root. More specific guidance applies within its subtree but
must not weaken root governance or security controls. Browser/UI work must also read
`.ai/frontend-standards.md` when present.

Before selecting or adding any library, framework or tool, read `.ai/tooling-policy.md` and
`.ai/dependencies.md`. Use the context-specified choice. If no choice is specified, stop and ask the user
before adding one. When an approved choice becomes an ongoing project standard, update the relevant `.ai`
context, dependency manifest, lockfile and verification configuration in the same change.

Read `.ai/version-control-policy.md`. Never stage, commit, amend, tag, push, force-push, change branches,
rewrite history, open a pull request, approve, merge or publish repository changes. This remains prohibited
even when explicitly requested. Leave changes uncommitted and hand them to a human for inspection and manual
action through Git or an approved IDE.
