# Approval Matrix

Approvals required before merge or release, derived from `.ai/project-config.yml`.

| Change type | Risk low | Risk medium | Risk high / critical |
|-------------|----------|-------------|----------------------|
| Docs / non-runtime | 1 engineer | 1 engineer | Technical owner |
| Application code | 1 reviewer | Technical owner | Technical + business |
| Security / authz / data | Technical owner | Technical + security | Technical + business + security |
| Dependency / tooling add | Technical owner | Technical owner | Technical + architecture |
| Production config | Technical owner | Technical + business | Technical + business |

Current project risk: **{{RISK_CLASSIFICATION}}**
Data classification: **{{DATA_CLASSIFICATION}}**
Production criticality: **{{PRODUCTION_CRITICALITY}}**
