# Coding Standards

- Java 21; four spaces; UTF-8; no wildcard imports.
- Constructor injection only; fields are private and final where practical.
- Prefer records for immutable API DTOs; validate at boundaries.
- Methods do one job; names express intent; comments explain why.
- No empty catch blocks, swallowed exceptions, `System.out`, or logging of secrets.
- Use `Clock`, injected collaborators, and deterministic inputs for testable code.
- Return appropriate HTTP status codes and RFC 7807 problem details.
- Keep changes focused and preserve backward compatibility unless explicitly approved.

## Readability and testability

- Extract a collaborator when it represents a distinct responsibility, business policy, transformation, or external boundary.
- Use interfaces for meaningful substitution points such as repositories, gateways, clocks, file systems, messaging, and third-party services.
- Do not create an interface for every class or solely to make Mockito work. Prefer concrete classes for stable internal implementation details.
- Prefer dependency injection to static access and static mocking.
- Keep focused collaborators deterministic where possible: explicit inputs, explicit outputs, and no hidden global state.
- Use precise responsibility-based names such as `EmailNormalizer`, `CustomerMapper`, `EligibilityPolicy`, or `NotificationGateway`.
- Avoid generic containers named `Helper`, `Utils`, `Common`, `Manager`, or `Processor`; these often hide unrelated behaviour.
- Keep business rules out of static utility methods. Place them in named domain policies or application services.
- Extract mapping, validation, formatting, or calculation logic when it obscures the primary flow or is independently reusable/testable.
- Do not add abstraction speculatively. Extract only when the boundary or responsibility is real and improves comprehension, substitution, or independent testing.
