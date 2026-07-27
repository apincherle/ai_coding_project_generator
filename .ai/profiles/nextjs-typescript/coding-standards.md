# Coding Standards - Next.js TypeScript

- Enable strict TypeScript and validate untrusted boundary data.
- Make server and client component boundaries explicit; add `"use client"` only when interaction requires it.
- Keep secrets, privileged data access and authorization checks on the server.
- Treat Server Actions, route handlers and middleware as security-sensitive entry points.
- Keep components focused; use pure domain functions and named services outside rendering code.
- Use interfaces/types for real contracts and adapters, not for every component.
- Make caching, revalidation, dynamic rendering and request-specific data behaviour explicit.
- Avoid unnecessary effects, client-side data fetching and duplicated server/client validation.
- Use semantic HTML, accessible interactions and explicit loading/error/not-found states.
- Do not expose environment variables unless intentionally marked and reviewed for the browser bundle.
