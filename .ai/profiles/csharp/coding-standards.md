# Coding Standards - C#

- Use .NET 9, current C# language features, nullable reference types and warnings as errors.
- Use constructor injection and immutable records for boundary DTOs where appropriate.
- Use interfaces at genuine persistence or external-service boundaries, not for every service.
- Prefer concrete internal services and responsibility-named collaborators over generic helpers.
- Keep business rules out of controllers, extension-method dumping grounds and static global state.
- Validate request models and return stable Problem Details responses.
- Use async APIs end to end and pass cancellation tokens at I/O boundaries.
- Preserve public contracts and migrations unless a breaking change is approved.
