from typing import Protocol
from uuid import UUID

from .domain import Customer


class CustomerRepository(Protocol):
    def find_by_id(self, customer_id: UUID) -> Customer | None: ...

    def save(self, customer: Customer) -> Customer: ...


class InMemoryCustomerRepository:
    def __init__(self) -> None:
        self._customers: dict[UUID, Customer] = {}

    def find_by_id(self, customer_id: UUID) -> Customer | None:
        return self._customers.get(customer_id)

    def save(self, customer: Customer) -> Customer:
        self._customers[customer.id] = customer
        return customer
