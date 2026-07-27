from fastapi.testclient import TestClient

from customer_api.main import create_app
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
