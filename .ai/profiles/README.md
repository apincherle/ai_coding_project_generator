# Language Profiles

Profiles provide language-specific templates for the four active context files: project, coding standards,
testing and dependencies. Universal guidance remains in the root `.ai` directory.

Available profiles are `java`, `python`, `csharp`, `c`, `cpp`, `rust`, `scala`,
`typescript-node`, `javascript-node`, `react-typescript` and `nextjs-typescript`.

Use `scripts/activate-profile.ps1 <profile>` or `scripts/activate-profile.sh <profile>`,
then review and tailor the resulting root files.

Do not edit a profile to store product-specific business rules, credentials, environment names or client data.
