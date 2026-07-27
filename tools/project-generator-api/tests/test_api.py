import subprocess
from pathlib import Path

import pytest
from fastapi.testclient import TestClient

from generator_api.main import (
    CreateProjectRequest,
    app,
    normalize_destination,
    resolve_destination,
    run_create_project,
)


def test_health_ok() -> None:
    client = TestClient(app)
    response = client.get("/health")
    assert response.status_code == 200
    body = response.json()
    assert body["status"] == "ok"
    assert Path(body["catalogueRoot"]).is_dir()


def test_list_profiles_includes_java() -> None:
    client = TestClient(app)
    response = client.get("/profiles")
    assert response.status_code == 200
    names = {item["profile"] for item in response.json()}
    assert "java" in names
    assert "python" in names


def test_resolve_destination_parent_and_full_path() -> None:
    parent = resolve_destination("billing-api", r"C:\Workspace")
    assert parent.name == "billing-api"
    full = resolve_destination("billing-api", r"C:\Workspace\billing-api")
    assert full.name == "billing-api"
    forward = resolve_destination("billing-api", "C:/Workspace")
    assert forward.name == "billing-api"


def test_normalize_destination_strips_quotes() -> None:
    assert normalize_destination(r'  "C:\Tools\Workspace\Auth"  ') == r"C:\Tools\Workspace\Auth"
    assert normalize_destination("C:/Tools/Workspace/Auth") == "C:/Tools/Workspace/Auth"


def test_create_project_rejects_bad_name() -> None:
    client = TestClient(app)
    response = client.post(
        "/projects",
        data={
            "profile": "java",
            "project_name": "bad name",
            "destination": str(Path.cwd()),
        },
    )
    assert response.status_code == 422


def test_create_project_form_accepts_windows_path() -> None:
    """Form encoding preserves single backslashes (unlike raw JSON in Swagger)."""
    client = TestClient(app)
    response = client.post(
        "/projects",
        data={
            "profile": "not-a-real-profile",
            "project_name": "billing-api",
            "destination": r"C:\Tools\Workspace\Auth",
        },
    )
    assert response.status_code == 422
    detail = str(response.json())
    assert "Unknown profile" in detail or "profile" in detail.lower()


def test_create_project_json_accepts_forward_slashes() -> None:
    client = TestClient(app)
    response = client.post(
        "/projects/json",
        json={
            "profile": "not-a-real-profile",
            "project_name": "billing-api",
            "destination": "C:/Tools/Workspace/Auth",
        },
    )
    assert response.status_code == 422
    detail = str(response.json())
    assert "Unknown profile" in detail or "profile" in detail.lower()


@pytest.mark.parametrize(
    "field,value",
    [
        ("entity_name", "not-pascal-case"),
        ("risk_classification", "extreme"),
        ("data_classification", "top-secret"),
    ],
)
def test_create_project_json_rejects_invalid_optional_fields(field: str, value: str) -> None:
    client = TestClient(app)
    payload = {
        "profile": "python",
        "project_name": "billing-api",
        "destination": "C:/Tools/Workspace/Auth",
        field: value,
    }
    response = client.post("/projects/json", json=payload)
    assert response.status_code == 422
    assert field in str(response.json())


def test_create_project_json_accepts_valid_optional_fields() -> None:
    """Valid optional metadata should pass validation (fails later at the missing-script stage)."""
    client = TestClient(app)
    payload = {
        "profile": "python",
        "project_name": "billing-api",
        "destination": "C:/Tools/Workspace/Auth",
        "entity_name": "Account",
        "description": "Customer account management API",
        "technical_owner": "@platform-engineering",
        "business_owner": "@product-owners",
        "risk_classification": "high",
        "data_classification": "confidential",
    }
    response = client.post("/projects/json", json=payload)
    # Not 422: the optional fields themselves are valid. The destination is real on this
    # machine, so this may reach the script and fail for other environment reasons instead.
    assert response.status_code != 422


def test_config_path_rejects_outside_manifests() -> None:
    client = TestClient(app)
    response = client.post(
        "/projects/json",
        json={
            "profile": "python",
            "project_name": "billing-api",
            "destination": "C:/Tools/Workspace/Auth",
            "config_path": "C:/Windows/win.ini",
        },
    )
    assert response.status_code == 422
    assert "manifests" in str(response.json()).lower()


def test_config_path_accepts_manifests_relative() -> None:
    # Validation of path only — request may later fail for other reasons.
    req = CreateProjectRequest(
        profile="python",
        project_name="billing-api",
        destination="C:/Tools/Workspace/Auth",
        config_path="project-config.ci.yml",
    )
    assert req.config_path == "project-config.ci.yml"


def test_run_create_project_forwards_optional_arguments(monkeypatch: pytest.MonkeyPatch) -> None:
    captured: dict[str, list[str]] = {}

    def fake_run(command: list[str], **kwargs: object) -> subprocess.CompletedProcess[str]:
        captured["command"] = command
        return subprocess.CompletedProcess(command, 0, stdout="ok", stderr="")

    monkeypatch.setattr(subprocess, "run", fake_run)

    request = CreateProjectRequest(
        profile="python",
        project_name="billing-api",
        destination=r"C:\Tools\Workspace\Auth",
        entity_name="Account",
        description="Account management API",
        technical_owner="@platform-engineering",
        business_owner="@product-owners",
        risk_classification="high",
        data_classification="confidential",
        production_criticality="medium",
        deployment_target="kubernetes",
    )
    run_create_project(request, r"C:\Tools\Workspace\Auth\billing-api")

    command = captured["command"]
    assert "-EntityName" in command and "Account" in command
    assert "-RiskClassification" in command and "high" in command
    assert "-DataClassification" in command and "confidential" in command
    assert "-TechnicalOwner" in command and "@platform-engineering" in command
    assert "-BusinessOwner" in command and "@product-owners" in command
    assert "-ValidationMode" in command and "draft" in command
    assert "-ConfigPath" not in command


def test_run_create_project_omits_unset_optional_arguments(monkeypatch: pytest.MonkeyPatch) -> None:
    captured: dict[str, list[str]] = {}

    def fake_run(command: list[str], **kwargs: object) -> subprocess.CompletedProcess[str]:
        captured["command"] = command
        return subprocess.CompletedProcess(command, 0, stdout="ok", stderr="")

    monkeypatch.setattr(subprocess, "run", fake_run)

    request = CreateProjectRequest(
        profile="python",
        project_name="billing-api",
        destination=r"C:\Tools\Workspace\Auth",
    )
    run_create_project(request, r"C:\Tools\Workspace\Auth\billing-api")

    command = captured["command"]
    for flag in (
        "-ConfigPath",
        "-EntityName",
        "-Description",
        "-TechnicalOwner",
        "-BusinessOwner",
        "-RiskClassification",
        "-DataClassification",
        "-ProductionCriticality",
        "-DeploymentTarget",
    ):
        assert flag not in command
    assert "-ValidationMode" in command
