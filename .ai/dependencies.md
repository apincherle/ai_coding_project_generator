# Dependency Policy

Use supported releases from approved repositories. Justify additions in the PR. Scan CVEs and licences; avoid duplicate libraries.
Runnable templates also standardise multistage Docker images with a baked ``development`` toolchain
(Compose ``target: development`` + Dev Container on that image). Keep `.env` secrets out of Git.

Catalogue operator tooling may use FastAPI + Uvicorn (+ python-multipart for form bodies) for the
local project-generator Swagger UI under `tools/project-generator-api` (binds to localhost by default).
Form fields accept unescaped Windows paths in Swagger Try it out.
