# Testing Standard - JavaScript Node

Use Vitest or Jest consistently, with Supertest/HTTP clients and Testcontainers where boundaries matter.
Test observable values, responses, persisted state and errors.
Mock external adapters rather than every internal module.
Every test must contain a meaningful `expect` assertion; spy/call verification alone is insufficient.
Test validation, authorization, rejected promises, timeouts and process-level failure paths.
Keep timers, environment variables, ports and shared module state isolated.
