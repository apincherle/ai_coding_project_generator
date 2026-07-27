"""HTTP API + Swagger UI that drives scripts/create-project.ps1."""

from __future__ import annotations

import json
import os
import re
import subprocess
from functools import lru_cache
from pathlib import Path
from shutil import which
from typing import Annotated

from fastapi import FastAPI, Form, HTTPException
from fastapi.exceptions import RequestValidationError
from fastapi.openapi.utils import get_openapi
from pydantic import BaseModel, Field, ValidationError, field_validator

PROJECT_NAME_PATTERN = re.compile(r"^[A-Za-z0-9][A-Za-z0-9._-]*$")


def catalogue_root() -> Path:
    """tools/project-generator-api/src/generator_api/main.py -> repo root."""
    return Path(__file__).resolve().parents[4]


def profiles_manifest_path() -> Path:
    return catalogue_root() / "manifests" / "profiles.json"


def create_project_script() -> Path:
    return catalogue_root() / "scripts" / "create-project.ps1"


@lru_cache(maxsize=1)
def load_profiles() -> dict:
    path = profiles_manifest_path()
    if not path.is_file():
        raise FileNotFoundError(f"Profile manifest missing: {path}")
    data = json.loads(path.read_text(encoding="utf-8"))
    return data.get("profiles", {})


def profile_names() -> list[str]:
    return sorted(load_profiles().keys())


def normalize_destination(value: str) -> str:
    """Accept Windows paths with single backslashes, forward slashes, or quoting."""
    cleaned = value.strip().strip('"').strip("'")
    if not cleaned:
        raise ValueError("destination must not be blank")
    return cleaned


class CreateProjectRequest(BaseModel):
    profile: str = Field(
        description="Language/stack profile from manifests/profiles.json",
        examples=["java"],
    )
    project_name: str = Field(
        description="New project name (also used for <project_name>.md AI context file)",
        min_length=1,
        max_length=80,
        examples=["billing-api"],
    )
    destination: str = Field(
        description=(
            "Parent folder OR full project path. "
            "In Swagger form fields, paste normally: C:\\Tools\\Workspace\\Auth "
            "(JSON clients may use C:/Tools/Workspace/Auth or escaped backslashes)."
        ),
        examples=[r"C:\Tools\Workspace\Auth", "C:/Tools/Workspace/Auth"],
    )

    @field_validator("profile")
    @classmethod
    def validate_profile(cls, value: str) -> str:
        names = profile_names()
        if value not in names:
            raise ValueError(f"Unknown profile '{value}'. Available: {', '.join(names)}")
        return value

    @field_validator("project_name")
    @classmethod
    def validate_project_name(cls, value: str) -> str:
        if not PROJECT_NAME_PATTERN.fullmatch(value):
            raise ValueError(
                "project_name must match ^[A-Za-z0-9][A-Za-z0-9._-]*$ "
                "(start with alphanumeric; letters, digits, ., _, - only)"
            )
        return value

    @field_validator("destination")
    @classmethod
    def validate_destination(cls, value: str) -> str:
        return normalize_destination(value)


class ProfileSummary(BaseModel):
    profile: str
    display_name: str
    category: str
    maturity: str
    verification: str


class CreateProjectResponse(BaseModel):
    project_name: str
    profile: str
    destination: str
    project_context_file: str
    message: str
    script_output: str


def resolve_destination(project_name: str, destination: str) -> Path:
    requested = Path(normalize_destination(destination)).expanduser()
    # Path accepts both \ and /; resolve after expand.
    requested = requested.resolve()
    if requested.name.lower() == project_name.lower():
        return requested
    return (requested / project_name).resolve()


def find_powershell() -> str:
    for candidate in ("pwsh", "powershell"):
        found = which(candidate)
        if found:
            return found
    raise HTTPException(
        status_code=500,
        detail=(
            "Neither pwsh nor powershell was found on PATH. "
            "Install PowerShell to run the generator."
        ),
    )


def run_create_project(
    profile: str, project_name: str, destination: str
) -> subprocess.CompletedProcess[str]:
    script = create_project_script()
    if not script.is_file():
        raise HTTPException(status_code=500, detail=f"Generator script missing: {script}")

    shell = find_powershell()
    command = [
        shell,
        "-NoProfile",
        "-File",
        str(script),
        "-Profile",
        profile,
        "-ProjectName",
        project_name,
        "-Destination",
        destination,
    ]
    return subprocess.run(
        command,
        check=False,
        capture_output=True,
        text=True,
        cwd=str(catalogue_root()),
        env={**os.environ},
    )


def create_project_impl(request: CreateProjectRequest) -> CreateProjectResponse:
    destination_path = resolve_destination(request.project_name, request.destination)
    if destination_path.exists() and any(destination_path.iterdir()):
        raise HTTPException(
            status_code=409,
            detail=f"Destination must not exist or must be empty: {destination_path}",
        )

    completed = run_create_project(
        request.profile, request.project_name, str(destination_path)
    )
    output = (completed.stdout or "") + (completed.stderr or "")
    if completed.returncode != 0:
        raise HTTPException(
            status_code=400,
            detail={
                "message": "create-project.ps1 failed",
                "exitCode": completed.returncode,
                "output": output.strip(),
            },
        )

    context_file = f"{request.project_name}.md"
    return CreateProjectResponse(
        project_name=request.project_name,
        profile=request.profile,
        destination=str(destination_path),
        project_context_file=context_file,
        message=(
            f"Created '{request.project_name}'. Enrich {context_file}, tailor .ai context, "
            "then verify. A human must inspect, stage, commit and push."
        ),
        script_output=output.strip(),
    )


app = FastAPI(
    title="AI Engineering Project Generator",
    description=(
        "Create a new governed repository from the AI Engineering Starter Kit. "
        "Use **Try it out** on **POST /projects** — form fields accept Windows paths as typed, "
        "e.g. `C:\\Tools\\Workspace\\Auth` (no JSON escaping).\n\n"
        "Default bind: `http://127.0.0.1:8090/docs`"
    ),
    version="0.1.0",
)


def custom_openapi() -> dict:
    if app.openapi_schema:
        return app.openapi_schema
    schema = get_openapi(
        title=app.title,
        version=app.version,
        description=app.description,
        routes=app.routes,
    )
    names = profile_names()
    components = schema.get("components", {}).get("schemas", {})
    for schema_name in ("CreateProjectRequest", "Body_create_project_projects_post"):
        request_schema = components.get(schema_name, {})
        properties = request_schema.get("properties", {})
        if "profile" in properties:
            properties["profile"]["enum"] = names

    # Form-encoded request body (Swagger Try it out fields)
    post = schema.get("paths", {}).get("/projects", {}).get("post", {})
    content = post.get("requestBody", {}).get("content", {})
    for media in ("application/x-www-form-urlencoded", "multipart/form-data"):
        props = content.get(media, {}).get("schema", {}).get("properties", {})
        if "profile" in props:
            props["profile"]["enum"] = names

    app.openapi_schema = schema
    return app.openapi_schema


app.openapi = custom_openapi  # type: ignore[method-assign]


@app.get("/health", tags=["ops"])
def health() -> dict[str, str]:
    return {"status": "ok", "catalogueRoot": str(catalogue_root())}


@app.get("/profiles", response_model=list[ProfileSummary], tags=["generator"])
def list_profiles() -> list[ProfileSummary]:
    profiles = load_profiles()
    return [
        ProfileSummary(
            profile=name,
            display_name=str(cfg.get("displayName", name)),
            category=str(cfg.get("category", "unknown")),
            maturity=str(cfg.get("maturity", "unknown")),
            verification=str(cfg.get("verification", "")),
        )
        for name, cfg in sorted(profiles.items(), key=lambda item: item[0])
    ]


@app.post(
    "/projects",
    response_model=CreateProjectResponse,
    tags=["generator"],
    summary="Create a project (form fields — paste Windows paths as-is)",
)
def create_project(
    profile: Annotated[
        str,
        Form(description="Language/stack profile from manifests/profiles.json"),
    ],
    project_name: Annotated[
        str,
        Form(description="New project name (also used for <project_name>.md)"),
    ],
    destination: Annotated[
        str,
        Form(
            description=(
                "Parent folder or full project path. "
                "Paste normally, e.g. C:\\Tools\\Workspace\\Auth — no escaping needed."
            ),
        ),
    ],
) -> CreateProjectResponse:
    try:
        request = CreateProjectRequest(
            profile=profile,
            project_name=project_name,
            destination=destination,
        )
    except ValidationError as exc:
        raise RequestValidationError(exc.errors()) from exc
    return create_project_impl(request)


@app.post(
    "/projects/json",
    response_model=CreateProjectResponse,
    tags=["generator"],
    summary="Create a project (JSON body)",
    description=(
        "Same as POST /projects but JSON. Prefer forward slashes "
        "(`C:/Tools/Workspace/Auth`) or escaped backslashes (`C:\\\\Tools\\\\...`)."
    ),
)
def create_project_json(request: CreateProjectRequest) -> CreateProjectResponse:
    return create_project_impl(request)
