# Dependency Policy - Java

Use Maven Central through approved repositories and platform-managed versions.
Justify additions in the pull request. Review licence, provenance, maintenance and CVEs.
Commit the Maven wrapper and use reproducible CI commands.
Approved local container tooling: Docker Engine, Docker Compose, and Dev Containers. Runnable templates
use multistage Dockerfiles with a ``development`` stage that bakes stack tooling from pinned images
(for example ``ghcr.io/astral-sh/uv``, ``maven``/Temurin, or ``mcr.microsoft.com/dotnet/sdk``) plus a
minimal ``production`` stage. Keep secrets out of Git.
