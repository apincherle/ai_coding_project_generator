# Testing Standard - Python

Use pytest, unittest.mock, HTTPX and Testcontainers.
Test observable behaviour and use fixtures with explicit scope.
Mock external boundaries rather than internal implementation details.
Every test must contain a meaningful `assert` about state, value, response, persisted data or exception.
Avoid sleep-based tests, uncontrolled randomness and tests that only assert a mock call.

Use pytest exclusively as the test runner. Prefer plain pytest functions and fixtures over unittest-style classes.
Create a fresh application/repository fixture per test or test scope; tests must not depend on module-global state
or execution order. Override FastAPI dependencies through the app instance and restore overrides after use.
Use `monkeypatch` only at true process/environment boundaries, not as a substitute for dependency injection.
Add tests proving that unknown Pydantic fields are rejected and configuration/startup failures are explicit.
