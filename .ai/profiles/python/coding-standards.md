# Coding Standards - Python

- Use Python 3.13, type annotations, UTF-8 and Ruff formatting.
- Use explicit dependency injection through FastAPI dependencies or constructor parameters.
- Use protocols or abstract interfaces at real external boundaries; do not abstract every class.
- Prefer small modules and responsibility-named collaborators over generic helpers.
- Keep domain rules out of route handlers and static/global utilities.
- Use Pydantic models at API boundaries and validate untrusted inputs.
- Avoid mutable global state, wildcard imports and broad exception catches.
- Keep public APIs and database migrations backward compatible unless approved.

## Dependable AI-generated Python

- Use Pydantic v2 models for external data, configuration and serialization boundaries.
- Configure boundary models with `extra="forbid"` unless forward-compatible extra fields are an explicit contract.
- Prefer immutable/frozen Pydantic models for commands and responses when mutation is unnecessary.
- Use an application factory such as `create_app(...)`; construct repositories, clients and services in a composition root.
- Never store mutable repositories, sessions, service objects, clients, caches or request state in module globals.
- Module-level constants and immutable metadata are acceptable when named and typed.
- Pass dependencies explicitly through constructors or FastAPI dependencies.
- Use `pydantic-settings` for environment configuration in production projects; validate configuration once at startup.
- Use protocols at external boundaries, but avoid speculative abstractions and service-locator dictionaries.
- Keep time, identifiers and randomness injectable when behaviour depends on them.
- Prefer pure functions and frozen dataclasses/Pydantic models for domain transformations.
