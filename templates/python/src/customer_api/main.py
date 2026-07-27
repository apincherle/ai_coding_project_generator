from typing import Annotated
from uuid import UUID

from fastapi import Depends, FastAPI, HTTPException, status
from pydantic import BaseModel, EmailStr, Field

from .repository import CustomerRepository, InMemoryCustomerRepository
from .service import CustomerNotFoundError, CustomerService


class CustomerRequest(BaseModel):
    model_config = {"extra": "forbid", "frozen": True}
    name: str = Field(min_length=1, max_length=200)
    email: EmailStr


class CustomerResponse(BaseModel):
    model_config = {"extra": "forbid", "frozen": True}
    id: UUID
    name: str
    email: str


def create_app(repository: CustomerRepository | None = None) -> FastAPI:
    customer_repository = repository or InMemoryCustomerRepository()
    application = FastAPI(title="Customer API", version="1.0.0")

    def get_service() -> CustomerService:
        return CustomerService(customer_repository)

    @application.post(
        "/api/v1/customers",
        response_model=CustomerResponse,
        status_code=status.HTTP_201_CREATED,
    )
    def create_customer(
        request: CustomerRequest,
        service: Annotated[CustomerService, Depends(get_service)],
    ) -> CustomerResponse:
        customer = service.create(request.name, str(request.email))
        return CustomerResponse.model_validate(customer, from_attributes=True)

    @application.get("/api/v1/customers/{customer_id}", response_model=CustomerResponse)
    def get_customer(
        customer_id: UUID,
        service: Annotated[CustomerService, Depends(get_service)],
    ) -> CustomerResponse:
        try:
            return CustomerResponse.model_validate(service.get(customer_id), from_attributes=True)
        except CustomerNotFoundError as error:
            raise HTTPException(status_code=404, detail="Customer not found") from error

    return application


app = create_app()
