# AI Engineering Starter Kit — Handbook

**Audience:** teams adopting the catalogue or presenting it  
**Purpose:** explain what the kit is, what is runnable today, and how to generate a product repo

## What this repository is

A **catalogue** of governed AI engineering practice:

- Shared policies under `.ai/`
- Language **profiles** (context templates)
- Installable **skills**
- **Generators** (`scripts/create-project.ps1`)
- Runnable reference apps for Java, Python and C#

It is **not** a product application. Do not clone the whole tree for ordinary delivery — generate a minimal project.

## Catalogue layout

| Path | Purpose |
|---|---|
| `AGENTS.md`, `CLAUDE.md`, `.cursor/rules` | Tool entrypoints |
| `.ai/` | Authoritative standards |
| `.ai/profiles/` | Per-language context templates |
| `skills/` | Codex-style skill procedures |
| `templates/java/` | Runnable Java generator template |
| `templates/python`, `templates/csharp` | Generator payloads |
| `scripts/` | activate-profile, create-project, verify |
| `manifests/profiles.json` | Profile registry + maturity |
| `hooks/`, `config/`, `.github/` | Local and CI gates |
| `docs/handouts/` | Presentation Markdown sources |
| Root / `docs/*.pdf` | Generated presentation PDFs |

## Profile maturity

| Maturity | Meaning | Profiles |
|---|---|---|
| **runnable** | Context + template/example + skills + verification | `java`, `python`, `csharp` |
| **scaffold** | Context only — add build/tests/CI yourself | C, C++, Rust, Scala, Node, React, Next.js |

List profiles:

```powershell
scripts\create-project.ps1 -ListProfiles
```

## Generate a product repository

```powershell
scripts\create-project.ps1 `
  -Profile java `
  -ProjectName product-api `
  -Destination C:\Workspace\product-api
```

Python / C# examples:

```powershell
scripts\create-project.ps1 -Profile python -ProjectName payments-api -Destination C:\Workspace\payments-api
scripts\create-project.ps1 -Profile csharp -ProjectName orders-api -Destination C:\Workspace\orders-api
```

Validate:

```powershell
scripts\validate-generated-project.ps1 C:\Workspace\payments-api
```

The generator copies governance + active profile context + recommended skills. It does **not** copy the full profile catalogue or unrelated languages.

## Activate a profile in this catalogue

```powershell
scripts\activate-profile.ps1 java
```

Replaces only: `.ai/project.md`, `coding-standards.md`, `testing.md`, `dependencies.md`. Review the diff before relying on it.

## Verification baselines

| Profile | Typical local check |
|---|---|
| Java | `mvn verify` (generated from `templates/java`) |
| Python | `uv run ruff … && uv run mypy src && uv run pytest` |
| C# | `dotnet format --verify-no-changes && dotnet build -warnaserror && dotnet test` |

## Presentation talking points

1. **Same rules for humans and AI** — Markdown in Git, not tribal knowledge.
2. **Skills load context** — one skill library, many repos.
3. **Gates are non-negotiable** — format, analyze, test, security.
4. **Human-only Git** — AI prepares; people publish.
5. **Generate, don’t clone** — product repos stay lean.
6. **Honest maturity** — three runnable stacks; others are scaffolds.

## After generating a product repo

1. Define product-specific content in `.ai/business-rules.md` and `.ai/domain-model.md`.
2. Record owners, data classification, integrations.
3. Confirm verification actually runs in CI.
4. Install matching skills.
5. Record the language/toolchain choice in an ADR.

## Related materials

- `docs/QUICKSTART.md` — adoption and language swap guide
- `docs/onboarding/GETTING_STARTED.md` — day-one setup
- `docs/handouts/01-standards-handout.md` — standards briefing
- `docs/handouts/02-skills-user-guide.md` — skills briefing
- Regenerated PDFs at repo root and under `docs/`
