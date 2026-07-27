# syntax=docker/dockerfile:1

ARG SDK_IMAGE=mcr.microsoft.com/dotnet/sdk:9.0
ARG RUNTIME_IMAGE=mcr.microsoft.com/dotnet/aspnet:9.0
ARG PORT=8080

# =============================================================================
# Development - .NET SDK (format, analyzers, test)
# =============================================================================
FROM ${SDK_IMAGE} AS development
ARG PORT
ENV PORT=${PORT} \
    ASPNETCORE_URLS=http://+:${PORT} \
    DOTNET_USE_POLLING_FILE_WATCHER=1
RUN apt-get update \
 && apt-get install -y --no-install-recommends git curl ca-certificates tini \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /workspace
COPY CustomerApi.slnx Directory.Build.props ./
COPY src ./src
COPY tests ./tests
RUN dotnet restore
EXPOSE ${PORT}
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["dotnet", "watch", "--project", "src/CustomerApi/CustomerApi.csproj", "run", "--no-launch-profile"]

# =============================================================================
# Build
# =============================================================================
FROM ${SDK_IMAGE} AS build
WORKDIR /src
COPY CustomerApi.slnx Directory.Build.props ./
COPY src ./src
COPY tests ./tests
RUN dotnet restore src/CustomerApi/CustomerApi.csproj \
 && dotnet publish src/CustomerApi/CustomerApi.csproj -c Release -o /app --no-restore

# =============================================================================
# Production (default)
# =============================================================================
FROM ${RUNTIME_IMAGE} AS production
ARG PORT
ENV ASPNETCORE_URLS=http://+:${PORT} \
    PORT=${PORT}
RUN apt-get update \
 && apt-get install -y --no-install-recommends curl \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=build /app .
USER $APP_UID
EXPOSE ${PORT}
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -fsS "http://127.0.0.1:${PORT}/health" || exit 1
ENTRYPOINT ["dotnet", "CustomerApi.dll"]
