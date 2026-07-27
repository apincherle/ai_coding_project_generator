from pathlib import Path

from fastapi.testclient import TestClient

from generator_api.main import app, normalize_destination, resolve_destination


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
