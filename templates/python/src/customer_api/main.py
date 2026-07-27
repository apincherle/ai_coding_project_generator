import uuid
from collections.abc import AsyncIterator, Awaitable, Callable
from contextlib import asynccontextmanager
from typing import Annotated
from uuid import UUID

from fastapi import Depends, FastAPI, HTTPException, Request, Response, status
from pydantic import BaseModel, EmailStr, Field
from starlette.middleware.base import BaseHTTPMiddleware

from .repository import CustomerRepository, InMemoryCustomerRepository
from .service import CustomerNotFoundError, CustomerService

CORRELATION_ID_HEADER = "X-Correlation-ID"
# Defence-in-depth request-body limit; the reverse proxy/ingress in front of this service
# should also enforce a body size limit at the edge.
MAX_REQUEST_BODY_BYTES = 1_000_000


class CorrelationIdMiddleware(BaseHTTPMiddleware):
    """Propagate an inbound correlation id, or generate one, for cross-service log correlation."""

    async def dispatch(
        self, request: Request, call_next: Callable[[Request], Awaitable[Response]]
    ) -> Response:
        correlation_id = request.headers.get(CORRELATION_ID_HEADER, str(uuid.uuid4()))
        request.state.correlation_id = correlation_id
        response = await call_next(request)
        response.headers[CORRELATION_ID_HEADER] = correlation_id
        return response


class RequestSizeLimitMiddleware(BaseHTTPMiddleware):
    """Reject requests whose declared Content-Length exceeds ``max_bytes``."""

    def __init__(self, app: FastAPI, max_bytes: int = MAX_REQUEST_BODY_BYTES) -> None:
        super().__init__(app)
        self._max_bytes = max_bytes

    async def dispatch(
        self, request: Request, call_next: Callable[[Request], Awaitable[Response]]
    ) -> Response:
        content_length = request.headers.get("content-length")
        if (
            content_length is not None
            and content_length.isdigit()
            and int(content_length) > self._max_bytes
        ):
            return Response(status_code=status.HTTP_413_CONTENT_TOO_LARGE)
        return await call_next(request)


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncIterator[None]:
    """Startup/shutdown extension point.

    Open pooled resources (database engines, HTTP clients) on startup and close them after the
    ``yield`` so in-flight requests drain before the process exits. Uvicorn forwards SIGTERM to
    this lifespan's shutdown phase; keep shutdown work fast and idempotent, and set
    ``--timeout-graceful-shutdown`` (or the orchestrator's termination grace period) to exceed
    the longest expected in-flight request.
    """
    yield


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
    application = FastAPI(title="Customer API", version="1.0.0", lifespan=lifespan)
    # Starlette's add_middleware() stubs narrow to a zero-argument constructor; the extra
    # ``max_bytes`` keyword (with a default) is valid at runtime but not expressible in the stub.
    application.add_middleware(RequestSizeLimitMiddleware)  # type: ignore[arg-type]
    application.add_middleware(CorrelationIdMiddleware)

    def get_service() -> CustomerService:
        return CustomerService(customer_repository)

    @application.get("/health", tags=["ops"])
    def health() -> dict[str, str]:
        """Liveness probe: the process is up and able to serve requests."""
        return {"status": "ok"}

    @application.get("/ready", tags=["ops"])
    def ready() -> dict[str, str]:
        """Readiness probe.

        The in-memory repository is always ready. Replace with a real connectivity check
        (e.g. a lightweight datastore ping) once a real backing store is introduced.
        """
        return {"status": "ready"}

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
