from fastapi.testclient import TestClient

from customer_api.main import CORRELATION_ID_HEADER, create_app
from customer_api.repository import InMemoryCustomerRepository


def test_creates_customer() -> None:
    app = create_app(InMemoryCustomerRepository())
    response = TestClient(app).post(
        "/api/v1/customers",
        json={"name": "Alice", "email": "alice@example.com"},
    )

    assert response.status_code == 201
    assert response.json()["name"] == "Alice"


def test_rejects_unknown_request_fields() -> None:
    app = create_app(InMemoryCustomerRepository())
    response = TestClient(app).post(
        "/api/v1/customers",
        json={"name": "Alice", "email": "alice@example.com", "admin": True},
    )

    assert response.status_code == 422


def test_health_reports_ok() -> None:
    app = create_app(InMemoryCustomerRepository())
    response = TestClient(app).get("/health")

    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_ready_reports_ready() -> None:
    app = create_app(InMemoryCustomerRepository())
    response = TestClient(app).get("/ready")

    assert response.status_code == 200
    assert response.json()["status"] == "ready"


def test_generates_correlation_id_when_absent() -> None:
    app = create_app(InMemoryCustomerRepository())
    response = TestClient(app).get("/health")

    assert response.headers[CORRELATION_ID_HEADER] != ""


def test_propagates_inbound_correlation_id() -> None:
    app = create_app(InMemoryCustomerRepository())
    response = TestClient(app).get("/health", headers={CORRELATION_ID_HEADER: "req-123"})

    assert response.headers[CORRELATION_ID_HEADER] == "req-123"


def test_rejects_oversized_request_body() -> None:
    app = create_app(InMemoryCustomerRepository())
    response = TestClient(app).post(
        "/api/v1/customers",
        headers={"content-length": "2000000"},
        content=b"{}",
    )

    assert response.status_code == 413
