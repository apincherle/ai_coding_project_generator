# AI Engineering Starter Kit

A production-oriented catalogue for consistent, secure AI-assisted development.
The repository is the durable context: people and AI tools read the same version-controlled rules.

Java, Python and C# are end-to-end runnable profiles with templates, skills, verification,
and multistage Docker/Compose/Dev Container assets (development toolchain baked from pinned images).
All other language profiles are standards-only scaffolds and require a product build/test payload.

## Quick start

1. Read `AGENTS.md` and `.ai/project.md`.
2. Install Java 21, Maven 3.9+, Docker, and Git.
3. Run `git config core.hooksPath hooks`.
4. Run `./scripts/verify.sh` (or `scripts\verify.ps1` on Windows).
5. Run `mvn verify` inside `templates/java` to verify the Java reference template.

## Non-negotiable gates

- Human ownership of every change and approval.
- No secrets, personal data, client data, or proprietary code in unapproved models.
- Every test contains at least one outcome assertion; interaction verification alone is insufficient.
- Formatting, static analysis, tests, dependency checks, secret scanning, and CI must pass.
- AI output is untrusted until inspected.

See `docs/onboarding/GETTING_STARTED.md`, `.ai/skills.md`, and `.ai/prompts.md`.
Presentation handouts: `docs/handouts/` (Markdown) and the generated PDFs listed in `docs/README.md`.

## Starting a new repository

Read `docs/QUICKSTART.md` before using this kit as a project template. It explains what to rename,
replace, retain or delete and how to activate backend, native, Node.js, React or Next.js context profiles.

### Option A — Swagger UI (recommended)

Requires **uv** and PowerShell (`pwsh` or `powershell`) on PATH.

```powershell
tools\project-generator-api\scripts\run.ps1
```

Then open http://127.0.0.1:8090/docs

1. Expand **POST /projects** → **Try it out**
2. Fill the form fields (not raw JSON):
   - `profile` — dropdown (e.g. `java`)
   - `project_name` — e.g. `billing-api`
   - `destination` — paste a normal Windows path, e.g. `C:\Tools\Workspace\Auth` (no escaping)
3. **Execute** — the API runs `scripts/create-project.ps1`

Stop the server with `Ctrl+C` in that terminal. Details: `tools/project-generator-api/README.md`.

### Option B — script

Create in a **parent folder** (project folder is created as `<Destination>\<ProjectName>`):

```powershell
scripts\create-project.ps1 -Profile java -ProjectName product-api -Destination C:\Workspace
```

Or pass the **full project path** (folder name must match `-ProjectName`):

```powershell
scripts\create-project.ps1 -Profile java -ProjectName product-api -Destination C:\Workspace\product-api
```

Each generated project includes ``<ProjectName>.md`` — product-specific AI context to enrich with purpose,
scope and working notes. Agents are instructed to read it before changing code.

Runnable profiles: `java`, `python`, `csharp`. Scaffold-only profiles still receive governance and
language context, but no application template or stack skills yet.

## Reusable development skills

The `skills/` directory contains Codex skills for Java (6), Python (4), and C# (4): feature work,
tests, review, and security review, plus Java diagnosis and refactor. Every skill loads the
repository's Markdown context before working. See `.ai/skills.md` for installation and invocation.
