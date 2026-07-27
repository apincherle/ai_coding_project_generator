# Starter Repository Quick Start

Use this guide when cloning the repository for a new product or changing its development language.

## Recommended: generate a minimal project

Do not clone the complete catalogue for ordinary product development. Generate a clean repository containing
only common governance and the selected stack:

```powershell
scripts\create-project.ps1 `
  -Profile java `
  -ProjectName customer-service `
  -Destination C:\Workspace\customer-service `
  -IncludeJavaExample
```

```powershell
scripts\create-project.ps1 `
  -Profile csharp `
  -ProjectName payments-api `
  -Destination C:\Workspace\payments-api
```

List profiles:

```powershell
scripts\create-project.ps1 -ListProfiles
```

Validate a generated project:

```powershell
scripts\validate-generated-project.ps1 C:\Workspace\payments-api
```

The generator does not copy `.ai/profiles/` or unrelated language tooling. Java-only skills and configurations
are included only for the Java profile. Generated projects record their source profile in `.ai/generation.json`.

Java, Python and C# currently include runnable Customer API reference implementations, stack-specific tests,
Dockerfiles, CI workflows, hooks and reusable skills. Other profiles currently generate standards scaffolds.

## Alternative: clone and rename the full catalogue

```text
git clone <starter-repository-url> my-service
cd my-service
git remote remove origin
git remote add origin <new-repository-url>
```

Update these files before generating code:

1. `.ai/project.md` - product name, purpose, runtime, framework, build and integrations.
2. `.ai/business-rules.md` - real business behaviour and invariants.
3. `.ai/domain-model.md` - real entities, value objects and terminology.
4. `.ai/dependencies.md` - approved repositories, libraries and version policy.
5. `README.md` - product-specific setup, ownership and operating instructions.
6. `.github/CODEOWNERS`, deployment configuration and environment names when added.

Do not leave example Customer API rules in a real project.

## 2. Choose a language profile

The root `.ai/*.md` files are the active context consumed by AI skills. Language profiles under
`.ai/profiles/` are source templates.

Available profiles:

- `java` - Java 21, Spring Boot 3.5, Maven, JUnit 5, Mockito, AssertJ and Testcontainers.
- `python` - Python 3.13, FastAPI, uv, pytest, unittest.mock, Ruff, mypy and Testcontainers.
- `csharp` - .NET 9, ASP.NET Core, NuGet, xUnit, NSubstitute, FluentAssertions and Testcontainers.
- `c` - C23, CMake, CTest, CMocka/Unity, sanitizers and native static analysis.
- `cpp` - C++23, CMake, GoogleTest/GoogleMock, sanitizers and clang tooling.
- `rust` - stable Rust 2024, Cargo, built-in tests, proptest and cargo security tooling.
- `scala` - Scala 3, sbt/scala-cli, MUnit/ScalaTest, property tests and JVM dependency controls.
- `typescript-node` - Node.js, strict TypeScript, a selected server framework and Vitest/Jest.
- `javascript-node` - Node.js with modern JavaScript when TypeScript is deliberately not selected.
- `react-typescript` - React, TypeScript, Vite, Testing Library, MSW, Playwright and accessibility checks.
- `nextjs-typescript` - Next.js/React with explicit server-client, caching and deployment guidance.

Activate a profile with:

```powershell
scripts\activate-profile.ps1 java
scripts\activate-profile.ps1 python
scripts\activate-profile.ps1 csharp
scripts\activate-profile.ps1 c
scripts\activate-profile.ps1 cpp
scripts\activate-profile.ps1 rust
scripts\activate-profile.ps1 scala
scripts\activate-profile.ps1 typescript-node
scripts\activate-profile.ps1 javascript-node
scripts\activate-profile.ps1 react-typescript
scripts\activate-profile.ps1 nextjs-typescript
```

or:

```sh
./scripts/activate-profile.sh java
```

Activation replaces only these active context files:

```text
.ai/project.md
.ai/coding-standards.md
.ai/testing.md
.ai/dependencies.md
```

Review the resulting diff and tailor it to the project. Never activate a profile over uncommitted context
changes without reviewing or preserving them.

## 3. Keep, tailor, replace or delete

| Area | Java project | Python project | C# project |
|---|---|---|---|
| `.ai/security.md`, governance, API and business context | Keep and tailor | Keep and tailor | Keep and tailor |
| Active language files | Activate Java profile | Activate Python profile | Activate C# profile |
| `examples/spring-api/` | Keep as reference or replace with product | Delete | Delete |
| Java-specific skills | Keep | Delete or replace | Delete or replace |
| Git hooks and verification scripts | Use Maven commands | Replace with uv/Ruff/pytest/mypy | Replace with dotnet commands |
| `config/checkstyle.xml`, PMD and SpotBugs | Keep | Delete | Delete |
| Python Ruff/mypy configuration | Delete unless polyglot | Add `pyproject.toml` | Delete |
| .NET analyzers/editor configuration | Delete unless polyglot | Delete | Add `.editorconfig` and analyzer rules |
| GitHub Actions | Use Maven workflow | Replace with Python workflow | Replace with .NET workflow |
| Docker and deployment | Replace image/build details | Replace image/build details | Replace image/build details |

Do not retain unused quality tools merely for appearance. Every configured gate must run, be maintained and
have an accountable owner.

## 4. Update the reusable skills

The supplied skills named `*-java-*` or containing Spring-specific instructions are Java-oriented.

For Java:

- Keep all six skills.
- Update repository context rather than copying project facts into the skill.

For Python, C#, C, C++, Rust or Scala:

- Remove Java-specific skill folders from `skills/`.
- Create language-specific equivalents such as:
  - `create-python-feature`, `generate-python-tests`, `review-python-change`
  - `create-dotnet-feature`, `generate-dotnet-tests`, `review-dotnet-change`
  - `create-native-feature`, `generate-native-tests`, `review-native-change` for C/C++
  - `create-rust-feature`, `generate-rust-tests`, `review-rust-change`
  - `create-scala-feature`, `generate-scala-tests`, `review-scala-change`

For Node and browser projects:

- Use `typescript-node` for new Node services unless JavaScript is an explicit project decision.
- Use `react-typescript` for a client-rendered Vite application.
- Use `nextjs-typescript` when the product requires Next.js server rendering, routing or full-stack capabilities.
- Create skills such as `create-react-feature`, `generate-ui-tests`, `review-frontend-change` and
  `accessibility-review`; each must load `.ai/frontend-standards.md`.
- Preserve the common workflow: load active `.ai/*.md`, confirm requirements, implement the smallest change,
  add behavioural assertions, run language-specific verification and report evidence.
- Update `.ai/skills.md`, `AGENTS.md` and tool-specific wrappers with the installed skill names.

Security review and governance procedures can remain mostly language-neutral, but their implementation checks
must name the selected framework and ecosystem.

## Additional language replacement map

| Profile | Remove from Java starter | Add or replace |
|---|---|---|
| C | Spring example, Maven workflow, Java analyzers | CMake presets, compiler matrix, CTest, CMocka/Unity, clang tooling and sanitizer jobs |
| C++ | Spring example, Maven workflow, Java analyzers | CMake presets, GoogleTest/GoogleMock, clang tooling, ABI policy and sanitizer jobs |
| Rust | Spring example, Maven workflow, Java analyzers | Cargo project, rust-toolchain policy, rustfmt, Clippy, cargo audit/deny and optional Miri/loom |
| Scala | Spring example unless using a Scala Spring stack, Java-only analyzers | sbt/scala-cli project, chosen HTTP/effect stack, Scalafmt, Scalafix and Scala test framework |
| TypeScript Node | Spring example, Maven workflow, Java analyzers | package manager lockfile, strict tsconfig, ESLint/Prettier, typecheck, Vitest/Jest and Node CI |
| JavaScript Node | Spring example, Maven workflow, Java analyzers | documented reason for JavaScript, ESLint/Prettier, tests and Node CI |
| React TypeScript | Spring example unless monorepo, backend-only workflows | Vite/React app, frontend standards, Testing Library, MSW, Playwright and accessibility checks |
| Next.js TypeScript | Spring example unless monorepo, backend-only workflows | Next.js app, server/client policy, browser tests, accessibility and deployment checks |

## 5. Replace the quality toolchain

### Java

```text
mvn spotless:check checkstyle:check test
mvn verify
```

### Python

```text
uv sync --frozen
uv run ruff format --check .
uv run ruff check .
uv run mypy src
uv run pytest
```

The generated Python API uses strict Pydantic boundary models, pytest, an application factory and explicit
repository injection. Do not introduce mutable module-level repositories, sessions, clients, caches, services
or settings. Prefer fresh fixtures, validated startup configuration and injectable time/identifier sources.

### C#

```text
dotnet restore --locked-mode
dotnet format --verify-no-changes
dotnet build --no-restore -warnaserror
dotnet test --no-build
```

### C

```text
cmake --preset ci
cmake --build --preset ci
ctest --preset ci --output-on-failure
```

Run the configured compiler warnings, clang-tidy and sanitizer presets in CI.

### C++

```text
cmake --preset ci
cmake --build --preset ci
ctest --preset ci --output-on-failure
```

Run clang-format, clang-tidy and the supported sanitizer matrix.

### Rust

```text
cargo fmt --check
cargo clippy --all-targets --all-features -- -D warnings
cargo test --all-targets --all-features
cargo audit
```

### Scala

```text
sbt scalafmtCheckAll scalafixAll --check test
```

Add the organisation-approved dependency, coverage and packaging checks.

### TypeScript or JavaScript Node

```text
corepack enable
pnpm install --frozen-lockfile
pnpm format:check
pnpm lint
pnpm typecheck     # TypeScript profile
pnpm test
```

### React or Next.js TypeScript

```text
pnpm install --frozen-lockfile
pnpm format:check
pnpm lint
pnpm typecheck
pnpm test
pnpm test:e2e
```

Add automated accessibility checks and framework-specific production builds.

Keep fast checks in pre-commit and the complete verification in pre-push and CI. CI remains authoritative.

## 6. Remove starter-only material

Delete or replace:

- `examples/spring-api/` after the team no longer needs the reference.
- Customer-specific content in `.ai/business-rules.md` and `.ai/domain-model.md`.
- Example MCP server entries not approved for the project.
- CI workflows for unused languages or publishing targets.
- Tool configurations that are not executed.
- Example Docker images, ports, database names and local credentials.
- Generated PDFs if the product repository should link to centrally maintained standards instead.

Keep:

- `AGENTS.md`
- `.ai/security.md`, `.ai/governance.md`, `.ai/api-guidelines.md` and `.ai/skills.md`
- ADR, threat-model, definition-of-done and pull-request templates
- One active language profile and its functioning gates
- Audit and human-approval requirements

## 7. Validate the new repository

Before the first feature:

- [ ] Product purpose, owner, data classification and risk level are documented.
- [ ] Customer example terminology has been removed.
- [ ] One language profile is active and internally consistent.
- [ ] Build, format, static analysis and tests run locally and in CI.
- [ ] Hooks point to real commands for the selected language.
- [ ] At least one representative test proves an outcome with a real assertion.
- [ ] Installed skills load the active `.ai/*.md` files.
- [ ] Secrets and environment configuration are external to Git.
- [ ] README, CODEOWNERS, reviewers and escalation routes are current.
- [ ] The initial ADR records the selected language, framework and quality toolchain.

## Adding a library or tool

Do not let an AI assistant select a new package implicitly. It must first read `.ai/tooling-policy.md`,
`.ai/dependencies.md` and the active language context. If no approved choice exists, it must ask the user
before adding one and clarify whether the choice is task-local or an ongoing project standard. Ongoing
standards must update the relevant `.ai` context, manifest, lockfile, CI and hooks in the same change.

## Human-only commit and push

AI assistants must leave all generated or edited files uncommitted. They may inspect status and diffs and run
verification, but must never stage, commit, amend, tag, push, change branches, rewrite history, open a pull
request or delegate those actions. The accountable developer must inspect, stage, commit and push manually or
through an approved IDE. This rule is defined in `.ai/version-control-policy.md` and applies even when an AI is
explicitly asked to commit or push.

## Recommended repository model

Keep one universal policy layer and one active language profile:

```text
.ai/
  architecture.md
  api-guidelines.md
  security.md
  governance.md
  business-rules.md
  domain-model.md
  skills.md
  project.md              # active profile, tailored to project
  coding-standards.md     # active profile, tailored to project
  testing.md              # active profile, tailored to project
  dependencies.md         # active profile, tailored to project
  profiles/
    java/
    python/
    csharp/
    c/
    cpp/
    rust/
    scala/
    typescript-node/
    javascript-node/
    react-typescript/
    nextjs-typescript/
```

For a monorepository, keep root governance and add scoped application context:

```text
AGENTS.md
.ai/
  security.md
  governance.md
apps/
  api/
    AGENTS.md
    .ai/
      project.md
      coding-standards.md
      testing.md
  web/
    AGENTS.md
    .ai/
      project.md
      coding-standards.md
      testing.md
```

This prevents three complete copies of governance and security guidance from drifting while still giving each
language an explicit, version-controlled engineering standard.
