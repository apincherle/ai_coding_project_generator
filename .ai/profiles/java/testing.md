# Testing Standard - Java

Use JUnit 5, Mockito, AssertJ, Spring Boot Test and Testcontainers.
Test observable behaviour with Arrange-Act-Assert. Mock external boundaries only.
Every test must contain a meaningful state, value, result or exception assertion; `verify(...)` alone is insufficient.
Use real PostgreSQL through Testcontainers for migrations, mappings and critical queries.
