# Architecture

Use a layered Spring Boot structure: web adapters -> application services -> persistence ports/adapters.
Controllers validate and translate HTTP; they contain no business rules. Services own use-case logic and
transaction boundaries. Repositories isolate persistence. DTOs do not leak JPA entities.

Dependencies point inward. Cross-cutting concerns use configuration or interceptors. Record significant
decisions in `docs/adr`. Avoid distributed systems, asynchronous messaging, or new infrastructure unless
the requirement justifies the operational cost.

## Interfaces and collaborators

Create interfaces at architectural boundaries where the application must substitute infrastructure or
external behaviour. Typical examples are persistence ports, notification gateways, remote service clients,
time sources, file storage, and message publishers. Keep the interface owned by the consuming application
or domain layer rather than by the infrastructure adapter.

Do not introduce an interface for every service implementation. Internal Spring services may remain concrete
when there is one stable implementation and no genuine boundary. Test concrete services through their public
behaviour and inject only the dependencies that cross a responsibility or system boundary.

Prefer small, cohesive collaborators with names that describe their role. A mapper, normalizer, validator,
policy, or calculator may be extracted when it clarifies the use-case flow and can be tested independently.
Avoid generic helper layers and pass-through wrappers that add indirection without enforcing a rule or isolating
a dependency.
