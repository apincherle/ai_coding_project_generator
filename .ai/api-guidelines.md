# API Guidelines

Use resource-oriented plural paths under `/api/v1`. JSON uses camelCase and ISO-8601 UTC timestamps.
Validate request bodies with Jakarta Validation. Use UUID identifiers. Support pagination for collections.
Document endpoints and schemas with OpenAPI. Do not expose stack traces or persistence details.
Use 200/201/204 for success; 400 validation; 404 missing; 409 conflicts; 500 unexpected failures.
Version breaking changes and include contract tests for compatibility-sensitive endpoints.
