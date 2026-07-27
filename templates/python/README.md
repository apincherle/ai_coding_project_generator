# Customer API (Python template)

Generated projects replace this file. Kept so container builds that bind-mount
`pyproject.toml` / packaging metadata have a README present.

## Software Bill of Materials (SBOM)

CI generates a CycloneDX SBOM (`sbom.json`) on every build via
`uv run pip-audit --format cyclonedx-json --output sbom.json` and uploads it as a build
artifact. Generate it locally the same way; it is informational and does not gate the build
(the `pip-audit` vulnerability check above it is the enforced gate).
