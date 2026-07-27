# Language Profiles

Profiles provide language-specific templates for the four active context files: project, coding standards,
testing and dependencies. Universal guidance remains in the root `.ai` directory.

Maturity is recorded in `manifests/profiles.json`:

| Maturity | Meaning | Profiles |
|---|---|---|
| `runnable` | Context, template or example, skills, and verification path exist | `java`, `python`, `csharp` |
| `scaffold` | Context files only; no template, skills, or CI payload yet | `c`, `cpp`, `rust`, `scala`, `typescript-node`, `javascript-node`, `react-typescript`, `nextjs-typescript` |

Use `scripts/activate-profile.ps1 <profile>` or `scripts/activate-profile.sh <profile>`,
then review and tailor the resulting root files.

For a new product repository, prefer `scripts/create-project.ps1`. Scaffold profiles still generate
governance and language context, but you must add build files, tests and gates yourself.

Do not edit a profile to store product-specific business rules, credentials, environment names or client data.
