from unittest.mock import Mock
from uuid import uuid4

import pytest

from customer_api.domain import Customer
from customer_api.repository import CustomerRepository
from customer_api.service import CustomerNotFoundError, CustomerService


def test_returns_customer() -> None:
    customer = Customer(uuid4(), "Alice", "alice@example.com")
    repository = Mock(spec=CustomerRepository)
    repository.find_by_id.return_value = customer

    result = CustomerService(repository).get(customer.id)

    assert result.name == "Alice"


def test_reports_missing_customer() -> None:
    repository = Mock(spec=CustomerRepository)
    repository.find_by_id.return_value = None

    with pytest.raises(CustomerNotFoundError):
        CustomerService(repository).get(uuid4())
