from uuid import UUID, uuid4

from .domain import Customer
from .repository import CustomerRepository


class CustomerNotFoundError(LookupError):
    pass


class CustomerService:
    def __init__(self, repository: CustomerRepository) -> None:
        self._repository = repository

    def get(self, customer_id: UUID) -> Customer:
        customer = self._repository.find_by_id(customer_id)
        if customer is None:
            raise CustomerNotFoundError(str(customer_id))
        return customer

    def create(self, name: str, email: str) -> Customer:
        return self._repository.save(Customer(id=uuid4(), name=name, email=email))
