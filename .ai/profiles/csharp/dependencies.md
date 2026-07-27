# Dependency Policy - C#

Use NuGet through approved feeds with a committed lock file.
Use central package management where appropriate.
Justify additions and review licence, provenance, maintenance and vulnerabilities.
Treat analyzer warnings as build failures unless a documented exception exists.
Approved local container tooling: Docker Engine, Docker Compose, and Dev Containers. The C# template
bakes the .NET 9 SDK into the ``development`` image (dotnet format, analyzers, xUnit) and publishes a
minimal ASP.NET runtime image for production. Keep secrets out of Git.
