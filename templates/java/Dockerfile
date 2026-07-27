# syntax=docker/dockerfile:1

ARG MAVEN_IMAGE=maven:3.9.9-eclipse-temurin-21
ARG JRE_IMAGE=eclipse-temurin:21-jre-jammy
ARG UID=10001
ARG GID=10001
ARG PORT=8080

# =============================================================================
# Development - JDK + Maven (Spotless, Checkstyle, tests available via mvn)
# =============================================================================
FROM ${MAVEN_IMAGE} AS development
ARG UID GID PORT
ENV PORT=${PORT}
RUN apt-get update \
 && apt-get install -y --no-install-recommends git curl ca-certificates tini \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && groupadd -g "${GID}" app \
 && useradd -l -u "${UID}" -g "${GID}" -m -s /bin/bash app
WORKDIR /workspace
COPY --chown=app:app pom.xml .
COPY --chown=app:app config ./config
COPY --chown=app:app src ./src
USER app
RUN mvn -B -DskipTests dependency:go-offline
EXPOSE ${PORT}
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["mvn", "-B", "spring-boot:run"]

# =============================================================================
# Build - package application jar
# =============================================================================
FROM ${MAVEN_IMAGE} AS build
WORKDIR /src
COPY pom.xml .
COPY config ./config
COPY src ./src
RUN mvn -B -DskipTests package

# =============================================================================
# Production - JRE only (default)
# =============================================================================
FROM ${JRE_IMAGE} AS production
ARG UID GID PORT
ENV PORT=${PORT}
RUN groupadd -g "${GID}" -r app \
 && useradd -l -u "${UID}" -g "${GID}" -r -m -N app
WORKDIR /app
COPY --from=build /src/target/customer-api-*.jar /app/app.jar
USER ${UID}
EXPOSE ${PORT}
HEALTHCHECK --interval=30s --timeout=5s --start-period=40s --retries=3 \
  CMD curl -fsS "http://127.0.0.1:${PORT}/actuator/health/liveness" || exit 1
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
