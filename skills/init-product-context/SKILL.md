---
name: init-product-context
description: Initialize or enrich a generated project's product context file, .ai/project-config.yml, and active profile after scaffolding. Use immediately after `create-project.ps1` runs, or when a project's product context still contains TODO placeholders.
---

# Initialize Product Context

## Product context requirement

Before acting, read `.ai/generation.json` to resolve `projectContextFile`, `profile`, `maturity`, and
`starterKitVersion`. Read `AGENTS.md` and `.ai/project-config.yml` completely. This skill exists to help
populate the very context that other skills depend on, so treat any remaining `TODO` in
`<ProjectName>.md` as work to finish, not as pre-existing acceptable content.

Read and obey `.ai/version-control-policy.md`. Never stage, commit, push, change branches, rewrite history,
or open/merge a pull request. Leave changes uncommitted for a human or approved IDE workflow.

## Gather facts

1. Ask the user (or infer from an existing brief/ticket) for: purpose, in-scope and out-of-scope boundaries,
   the primary domain entity, key systems/integrations, data classification, risk classification, and any
   constraint that changes the architecture or security posture.
2. Cross-check `entityName`, `owners`, `riskClassification`, `dataClassification`, `productionCriticality`,
   and `deploymentTarget` already present in `.ai/project-config.yml`; do not silently override a value a
   human already set without calling it out.
3. Confirm the active profile's verification baseline in `.ai/active-profile.md` matches what the team will
   actually run.

## Populate context

1. Replace every `TODO` in `<ProjectName>.md` (`Out of scope`, `Systems and integrations`, `Open decisions`)
   with concrete, current information; do not invent facts the user has not confirmed.
2. Keep secrets, production credentials, and client data out of the product context file.
3. If `owners`, classifications, or `deploymentTarget` in `.ai/project-config.yml` need correction, update
   the YAML directly and flag the change explicitly rather than silently rewriting identity fields.
4. Do not remove the references section pointing back to `.ai/project-config.yml`, `.ai/active-profile.md`,
   and governance documents.

## Report

List the fields populated or corrected, any fact the user still needs to confirm, and remind the user that
a human must still configure GitHub rulesets (`docs/github-rulesets.md`) and install hooks before treating
the project as ready for change.
