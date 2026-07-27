# Compatibility Matrix

Tracks the runtime, framework, and quality-gate versions each starter-kit release generates. Update this
table in the same change that bumps `VERSION` or a template's pinned runtime/framework version.

## Catalogue version 0.1.0

| Stack | Runtime | Framework | Build tool | Coverage gate | Dependency lock | Key security tooling |
| --- | --- | --- | --- | --- | --- | --- |
| Java | Temurin 21 | Spring Boot 3.5.0 | Maven (wrapped, `mvnw`) | JaCoCo `jacoco.line.coverage=0.70` | Maven `dependency:go-offline` cache (no lock file format in Maven) | ArchUnit, Checkstyle, PMD, SpotBugs, OWASP dependency-check (security profile) |
| Python | CPython 3.13 | FastAPI 0.115+ | uv | pytest-cov `fail_under=70` | `uv.lock` (committed) | import-linter, pip-audit, Ruff, mypy strict |
| C# | .NET 9 | ASP.NET Core (minimal APIs) | dotnet CLI | coverlet.collector `Threshold=70` via `coverlet.runsettings` | `packages.lock.json` (via `RestorePackagesWithLockFile`, generated on first `dotnet restore --use-lock-file`) | NuGet Audit, .NET analyzers (`AnalysisLevel=latest-recommended`) |

Cross-cutting for every runnable profile: Semgrep (`config/semgrep.yml`), gitleaks secret scanning, Trivy
filesystem scanning, and `scripts/check-exceptions.ps1` governance-exception expiry checks
(`.github/workflows/security.yml`).

## Compatibility notes

- **Java**: Spring Boot 3.5.x requires Java 17+; the template pins Java 21 (LTS). ArchUnit 1.4.x requires
  Java 11+. Upgrading the `spring-boot-starter-parent` major version is a breaking change requiring review
  of Jakarta namespace, actuator endpoint, and configuration-property changes.
- **Python**: FastAPI 0.115+ requires Pydantic v2. The template targets CPython 3.13; downgrading requires
  removing `>=3.13`-only syntax (e.g. some `typing` generic aliases) and re-validating `mypy --python-version`.
- **C#**: .NET 9 is a Standard Term Support (STS) release; plan the upgrade to the next LTS release ahead of
  its end-of-support date. `TreatWarningsAsErrors` means analyzer rule changes in a new SDK can fail builds
  until addressed.

## How to update this matrix

1. Bump the runtime/framework/tool version in the relevant `templates/<stack>` files.
2. Regenerate lock files (`uv lock`, `dotnet restore --use-lock-file`; Maven has no lock file to regenerate).
3. Re-run the stack's verification baseline (see `manifests/profiles.json` `verification`).
4. Add a new version row (or update the current one) here with the resulting versions and gate values.
5. Add a migration note to `docs/upgrades/migration-guide.md` if generated projects need any follow-up action.
