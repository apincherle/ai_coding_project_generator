# Project Context

Baseline: Java 21, Spring Boot 3.5, Maven, REST/JSON, PostgreSQL.
Testing: JUnit 5, Mockito, AssertJ, Spring Boot Test, Testcontainers.
Quality: Spotless, Checkstyle, PMD, SpotBugs, JaCoCo, OWASP Dependency-Check, Semgrep.
Containers: multistage Dockerfile with pinned tool images, a ``development`` stage that bakes
lint/test tooling, Compose ``target: development``, and a Dev Container that attaches to that image.

AI may propose and implement scoped changes, but a named human owns requirements, review, and merge.
Prefer boring, explicit, maintainable solutions over novelty.
