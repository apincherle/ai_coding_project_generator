# Testing Standard - TypeScript Node

Use Vitest or Jest consistently, with Supertest/HTTP clients and Testcontainers where boundaries matter.
Test observable values, responses, persisted state and errors.
Mock network, clock, storage and other external adapters rather than internal implementation details.
Every test must contain a meaningful `expect` assertion; spy/call verification alone is insufficient.
Test rejected promises, timeouts, validation, authorization and concurrency/idempotency paths.
Keep tests deterministic and isolate environment variables, ports, timers and shared process state.
