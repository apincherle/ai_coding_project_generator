# Coding Standards - JavaScript Node

- Use modern ECMAScript modules consistently and declare supported Node.js engines.
- Use JSDoc and `// @ts-check` for public modules and high-risk code where supported.
- Validate all untrusted data at process, HTTP, queue and persistence boundaries.
- Prefer factory functions, concrete modules and pure functions; introduce contracts only at real boundaries.
- Keep domain rules out of route handlers and generic helpers.
- Inject external clients, clocks, storage and messaging; avoid mutable module globals.
- Handle promises and errors explicitly and avoid blocking the event loop.
- Use structured logging with redaction and never evaluate untrusted code.
- Prefer TypeScript for new complex or long-lived services unless JavaScript is an explicit project decision.
