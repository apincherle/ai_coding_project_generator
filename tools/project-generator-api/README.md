# Project Generator API

FastAPI service with Swagger UI that drives `scripts/create-project.ps1`.

## Bring it up

Requires **uv** and PowerShell (`pwsh` or `powershell`) on PATH.

From the catalogue root:

```powershell
tools\project-generator-api\scripts\run.ps1
```

Or manually:

```powershell
cd tools\project-generator-api
uv sync
uv run uvicorn generator_api.main:app --app-dir src --host 127.0.0.1 --port 8090
```

Open Swagger UI: **http://127.0.0.1:8090/docs**

Stop with `Ctrl+C`. Default bind is localhost only (`127.0.0.1:8090`).

## Create a project in Swagger

1. Open **POST /projects** → **Try it out**
2. Use the **form fields** (not the JSON editor):
   - `profile` — e.g. `java`
   - `project_name` — e.g. `billing-api`
   - `destination` — paste as typed, e.g. `C:\Tools\Workspace\Auth`
3. **Execute**

`destination` may be a **parent folder** or the **full project path** (same rules as the script).
Form fields accept single-backslash Windows paths; no JSON escaping.

For programmatic JSON clients, use **POST /projects/json** with forward slashes
(`C:/Tools/Workspace/Auth`) or escaped backslashes (`C:\\Tools\\Workspace\\Auth`).

## Endpoints

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/health` | Liveness + catalogue root |
| GET | `/profiles` | Profiles from `manifests/profiles.json` |
| POST | `/projects` | Create a project (form — Swagger-friendly paths) |
| POST | `/projects/json` | Create a project (JSON body) |

Creates `<project_name>.md` product AI context and generated `AGENTS.md` that requires reading it.

## Security notes

- Binds to `127.0.0.1` by default (local operator tool).
- Validates `project_name` and invokes the script with an argument list (no shell string concat).
- Does not commit or push; human version-control policy still applies.
