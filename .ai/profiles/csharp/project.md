# Project Context - C# Profile

Baseline: .NET 9, C#, ASP.NET Core Minimal APIs or Controllers, Entity Framework Core, REST/JSON and PostgreSQL.
Testing: xUnit, NSubstitute, FluentAssertions, WebApplicationFactory and Testcontainers.
Quality: dotnet format, nullable reference types, built-in analyzers, coverage, dependency scanning and Semgrep.
Containers: multistage Dockerfile with the official .NET SDK ``development`` stage (format, analyzers,
xUnit), Compose ``target: development``, and a Dev Container that attaches to that image.

Replace this paragraph with the product purpose, owners, data classification, integrations and constraints.
AI may implement scoped changes, but a named human owns requirements, review and merge.
