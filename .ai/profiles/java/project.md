# Project Context - Java Profile

Baseline: Java 21, Spring Boot 3.5, Maven, REST/JSON and PostgreSQL.
Testing: JUnit 5, Mockito, AssertJ, Spring Boot Test and Testcontainers.
Quality: Spotless, Checkstyle, PMD, SpotBugs, JaCoCo, dependency scanning and Semgrep.
Containers: multistage Dockerfile with pinned tool images, a ``development`` stage that bakes
lint/test tooling (for example uv/ruff/mypy/pytest, JDK/Maven, or the .NET SDK), Compose
``target: development``, and a Dev Container that attaches to that image.

Replace this paragraph with the product purpose, owners, data classification, integrations and constraints.
AI may implement scoped changes, but a named human owns requirements, review and merge.
