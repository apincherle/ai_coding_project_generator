# Dependency Policy

Use supported releases from approved repositories. Justify additions in the PR. Scan CVEs and licences; avoid duplicate libraries.
Runnable templates also standardise multistage Docker images with a baked ``development`` toolchain
(Compose ``target: development`` + Dev Container on that image). Keep `.env` secrets out of Git.

Catalogue operator tooling may use FastAPI + Uvicorn (+ python-multipart for form bodies) for the
local project-generator Swagger UI under `tools/project-generator-api` (binds to localhost by default).
Form fields accept unescaped Windows paths in Swagger Try it out.

## Approved quality and security tooling (templates)

These tools are pre-approved for use in the runnable templates and any generated project derived
from them. Do not substitute alternatives without updating this file and the relevant template.

### Java

- **ArchUnit** — enforces the layering rules in `templates/java` (domain/repository must not depend
  on the web layer) via a JUnit test; runs in `mvn -B verify`.
- **JaCoCo** — line/branch coverage; the `jacoco-maven-plugin` `check` goal fails the build below
  the configured threshold (see `pom.xml`).
- **OWASP dependency-check-maven** — CVE scanning against the `security` Maven profile
  (`mvn -Psecurity verify`); fails on CVSS ≥ 7.
- **cyclonedx-maven-plugin** — generates a CycloneDX SBOM (`target/bom.json`) from the `security`
  profile; informational, does not gate the build.

### Python

- **pytest-cov** — coverage measurement; `[tool.coverage.report] fail_under = 70` in
  `pyproject.toml` gates `uv run pytest`.
- **import-linter** — enforces that `domain`/`repository` modules do not import FastAPI/Starlette/
  Uvicorn or the application entrypoint; configured under `[tool.importlinter]` in `pyproject.toml`
  and run via `uv run lint-imports`.
- **pip-audit** — CVE scanning of resolved dependencies; run via `uv run pip-audit --local
  --skip-editable` in CI and the pre-push hook, and also used to emit a CycloneDX SBOM
  (`--format cyclonedx-json`).

### C#

- **coverlet.collector** — line coverage via `dotnet test --collect:"XPlat Code Coverage"`;
  `coverlet.runsettings` sets a 70% line threshold that fails `dotnet test` below it.
- **NuGetAudit** (built into the .NET SDK) — CVE scanning at restore time; enabled via
  `NuGetAudit`/`NuGetAuditMode`/`NuGetAuditLevel` in `Directory.Build.props`, with audit advisory
  codes (`NU1901`–`NU1904`) promoted to errors.
- **Microsoft.CodeAnalysis.NetAnalyzers** (in-box with the SDK) — enabled via `EnableNETAnalyzers`
  and `AnalysisLevel=latest-recommended` in `Directory.Build.props` for design/dependency-direction
  diagnostics; no extra NuGet package required.
- **CycloneDX (dotnet tool)** — `dotnet tool install --global CycloneDX` + `dotnet CycloneDX` emits
  a CycloneDX SBOM from the locked restore; informational, does not gate the build.

### Cross-cutting (all stacks)

- **Semgrep** — static analysis rules in `config/semgrep.yml`, run by `.github/workflows/security.yml`.
- **gitleaks** — secret scanning (`secret-scan` job in `.github/workflows/security.yml`).
- **trivy** — filesystem/dependency vulnerability scanning (`container-scan` job in
  `.github/workflows/security.yml`).
- **CycloneDX** — SBOM format standardised across all three stacks (see per-stack tooling above);
  generated as a build artifact, not a merge gate.
