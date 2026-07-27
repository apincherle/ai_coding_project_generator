# Testing Standard - C#

Use xUnit, NSubstitute, FluentAssertions, WebApplicationFactory and Testcontainers.
Test observable behaviour with Arrange-Act-Assert.
Substitute external boundaries, not every internal class.
Every test must contain a meaningful FluentAssertions or xUnit assertion; received-call verification alone is insufficient.
Use real PostgreSQL through Testcontainers for migrations, mappings and critical queries.
