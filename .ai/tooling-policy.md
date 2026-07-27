# Library and Tool Selection Policy

This policy applies to runtime libraries, frameworks, test libraries, build tools, code generators,
linters, formatters, analyzers, deployment tools and AI/MCP integrations.

## Required decision sequence

1. Read `.ai/project.md`, `.ai/dependencies.md`, `.ai/coding-standards.md`, `.ai/testing.md` and the build/lock files.
2. If the required capability has an approved library or tool in context, use that choice and its documented version policy.
3. Do not silently substitute a preferred or familiar alternative.
4. If no choice is documented, stop before adding a dependency and ask the user to choose or approve one.
5. Present only the smallest credible options, including:
   - purpose and why existing platform capabilities are insufficient;
   - maintenance and ecosystem maturity;
   - licence and provenance;
   - security and supply-chain implications;
   - compatibility and operational cost;
   - test/build impact and likely lockfile changes.
6. Ask whether the choice is:
   - temporary or task-local, with no project-standard update; or
   - an ongoing project standard.
7. When the user approves an ongoing standard, add it to the relevant AI context in the same change:
   - `.ai/dependencies.md` for allowed dependency/tool and version policy;
   - `.ai/testing.md` for test tools and required usage;
   - `.ai/coding-standards.md` for framework/library conventions;
   - `.ai/project.md` for foundational runtime/framework/build choices.
8. Update the dependency manifest, lockfile, CI, hooks and documentation consistently.
9. Record the decision in an ADR when the choice materially affects architecture, security, operations or long-term coupling.

## Prohibited behaviour

- Adding or replacing a library/tool without context approval.
- Inventing a version, package name or compatibility claim.
- Bypassing the approved library because another tool is easier for the AI to use.
- Adding overlapping libraries that solve the same problem without an explicit migration decision.
- Updating context to imply approval before the user or authorised owner approves the choice.
- Treating development-only tools as exempt from licence, provenance or vulnerability review.

Reviews must flag dependencies or tools that are absent from AI context, lack approval evidence,
duplicate an existing capability, or were added without matching lockfile and verification updates.
