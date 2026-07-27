# Coding Standards - TypeScript Node

- Enable TypeScript strict mode and avoid `any`; use `unknown` plus validation for untrusted data.
- Validate process, HTTP, queue and persistence boundaries with the approved schema library.
- Use interfaces/types for meaningful contracts and external adapters, not for every class or function.
- Prefer concrete internal services, pure functions and responsibility-named modules.
- Keep domain logic outside route handlers and framework decorators.
- Use dependency injection for external clients, clocks, storage and messaging; avoid mutable module globals.
- Handle promises explicitly, propagate cancellation where supported and avoid blocking the event loop.
- Use structured logging with redaction. Never log secrets, tokens or sensitive request bodies.
- Keep ESM/CommonJS and build/output conventions consistent across the repository.
- Avoid generic helper modules and unsafe dynamic evaluation.
