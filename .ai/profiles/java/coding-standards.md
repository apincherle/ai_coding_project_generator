# Coding Standards - Java

- Use Java 21, UTF-8, four spaces and no wildcard imports.
- Use constructor injection. Keep fields private and final where practical.
- Use records for immutable boundary DTOs where appropriate.
- Use interfaces at genuine persistence or external-system boundaries, not for every class.
- Prefer concrete internal services and responsibility-named collaborators.
- Avoid generic helpers and static business logic.
- Validate at boundaries and return stable RFC 7807 problem details.
- Keep changes small, explicit and backward compatible unless approved.
