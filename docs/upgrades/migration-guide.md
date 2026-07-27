# Starter Kit Migration Guide

This guide is for two audiences:

- **Catalogue maintainers** bumping a template's pinned runtime, framework, or tool version.
- **Owners of a generated project** deciding whether and how to pull forward a newer starter-kit release.

The catalogue does not push changes into generated projects automatically. Every generated project records
the catalogue version it was created from in `.ai/generation.json` (`starterKitVersion`). Use
`scripts/upgrade-assessment.ps1` against a generated project to compare that value with the catalogue's
current `VERSION` and get a starting list of what changed.

## Versioning policy

The catalogue uses semantic versioning in `VERSION`:

- **Patch** (`0.1.x`): documentation, non-breaking tooling additions (new optional skill, additional CI
  check that does not change an existing gate's pass/fail behaviour).
- **Minor** (`0.x.0`): new profile, new skill set, or a quality-gate addition that a generated project must
  opt into (e.g. a new coverage threshold, a new required CI job).
- **Major** (`x.0.0`): breaking changes to `.ai/project-config.schema.yml`, the generation record schema
  (`schemaVersion` in `.ai/generation.json`), or a runtime/framework major-version bump in a template.

## General migration steps for a generated project

1. Run `scripts/upgrade-assessment.ps1 -ProjectPath <path-to-generated-project>` from the catalogue to see
   the version delta and a summary of catalogue changes since the project's `starterKitVersion`.
2. Diff the generated project's `AGENTS.md`, `.ai/*.md`, hooks, and CI workflows against the current
   catalogue templates for the same profile; the project's product-specific edits must be preserved.
3. Apply catalogue changes selectively — do not overwrite a generated project's product context, business
   rules, or domain model. Only pull forward standards, tooling, and enforcement changes.
4. Re-run the profile's verification baseline (`manifests/profiles.json` `verification`) after merging
   changes.
5. Update `.ai/generation.json` `starterKitVersion` to the catalogue version now in use once the migration
   is verified, so the next assessment has an accurate baseline.
6. A human must review, stage, commit, and push the migration; no AI workflow performs these steps.

## Stack-specific notes

### Java

- Lock file: Maven has no first-class lock file; re-run `mvn -B verify` after any parent POM or plugin
  version bump to catch resolution or plugin-behaviour changes early.
- Watch for Spring Boot actuator endpoint or configuration-property renames between minor versions.

### Python

- After bumping `pyproject.toml` constraints, run `uv lock` to regenerate `uv.lock`, then
  `uv sync --locked --all-groups` before running the verification baseline.
- Re-run `uv run lint-imports` after any package/module restructuring; the import-linter contract enforces
  that `customer_api.domain` and `customer_api.repository` never import the web layer.

### C#

- After bumping package versions, regenerate `packages.lock.json` with `dotnet restore --use-lock-file`
  (requires the .NET SDK) and commit the updated lock file alongside the version bump.
- NuGet Audit (`NuGetAudit=true`) will fail restore on newly disclosed vulnerabilities in already-pinned
  packages even without a version bump; treat that as a signal to assess and upgrade, not to suppress.

## Recording the migration

Add or update a row in `docs/upgrades/compatibility-matrix.md` for any runtime/framework/tool version
change, and note any generated-project follow-up action in this guide's stack-specific section above.
