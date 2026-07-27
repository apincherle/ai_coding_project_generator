# Testing Standard

Frameworks: JUnit 5, Mockito, AssertJ, Spring Boot Test, Testcontainers.
Use Arrange-Act-Assert. Test observable behaviour, positive and negative paths, validation, authorization,
and error mapping. Mock only process boundaries and slow/external dependencies.

Every test must include at least one meaningful outcome assertion such as `assertThat(result.name()).isEqualTo(...)`.
`verify(...)` alone is not a sufficient test. Avoid sleeps, random flakiness, shared mutable fixtures, and
implementation-coupled assertions. Integration tests use real PostgreSQL via Testcontainers.

## Designing for testability

- Test concrete application services through public behaviour; do not require an interface solely for unit testing.
- Mock interfaces at external or infrastructure boundaries. Avoid mocking every internal collaborator.
- Prefer injected clocks, gateways, repositories, clients, and deterministic policies over static calls or hidden global state.
- Test pure mappers, normalizers, calculators, and policies directly without mocks.
- Excessive mock setup is a design signal: reassess class responsibilities and boundaries before adding more mocks.
- Do not extract a helper merely to test a private method. Test the observable behaviour or extract a real responsibility with a domain-focused name.
