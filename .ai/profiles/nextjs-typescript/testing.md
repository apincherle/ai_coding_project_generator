# Testing Standard - Next.js TypeScript

Use the selected unit runner with React Testing Library, MSW and Playwright.
Test server utilities and domain logic directly; test client UI through accessible user-visible behaviour.
Use browser/integration tests for routing, authentication, server actions, caching-sensitive paths and hydration.
Every test must contain a meaningful outcome assertion; mock-call verification alone is insufficient.
Cover loading, error, not-found, authorization and server/client boundary failures.
Do not mock framework behaviour so heavily that rendering or routing contracts are no longer exercised.
