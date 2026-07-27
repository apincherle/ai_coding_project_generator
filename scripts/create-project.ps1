[CmdletBinding(DefaultParameterSetName = "Create")]
param(
    [Parameter(ParameterSetName = "Create", Mandatory = $true)]
    [string]$Profile,

    [Parameter(ParameterSetName = "Create", Mandatory = $true)]
    [ValidatePattern("^[A-Za-z0-9][A-Za-z0-9._-]*$")]
    [string]$ProjectName,

    [Parameter(ParameterSetName = "Create", Mandatory = $true)]
    [Alias("Path", "Location", "OutDir")]
    [string]$Destination,

    [Parameter(ParameterSetName = "List", Mandatory = $true)]
    [switch]$ListProfiles
)

$ErrorActionPreference = "Stop"
$catalogRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$manifestPath = Join-Path $catalogRoot "manifests\profiles.json"
$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json

if ($ListProfiles) {
    $manifest.profiles.PSObject.Properties | ForEach-Object {
        $maturity = if ($_.Value.PSObject.Properties.Name -contains "maturity") { $_.Value.maturity } else { "unknown" }
        [PSCustomObject]@{
            Profile = $_.Name
            Description = $_.Value.displayName
            Category = $_.Value.category
            Maturity = $maturity
        }
    } | Format-Table -AutoSize
    exit 0
}

$profileProperty = $manifest.profiles.PSObject.Properties[$Profile]
if ($null -eq $profileProperty) {
    $available = ($manifest.profiles.PSObject.Properties.Name -join ", ")
    throw "Unknown profile '$Profile'. Available profiles: $available"
}
$profileConfig = $profileProperty.Value

# Destination may be either:
# 1) the new project root (leaf folder name equals ProjectName), or
# 2) a parent location - the project is created at <Destination>/<ProjectName>
$requestedDestination = [System.IO.Path]::GetFullPath($Destination)
$destinationLeaf = Split-Path -Leaf $requestedDestination
if ($destinationLeaf -ieq $ProjectName) {
    $destinationPath = $requestedDestination
} else {
    $destinationPath = [System.IO.Path]::GetFullPath((Join-Path $requestedDestination $ProjectName))
}

if (Test-Path -LiteralPath $destinationPath) {
    $existing = @(Get-ChildItem -LiteralPath $destinationPath -Force)
    if ($existing.Count -gt 0) {
        throw "Destination must not exist or must be empty: $destinationPath"
    }
} else {
    New-Item -ItemType Directory -Force -Path $destinationPath | Out-Null
}

function Copy-CatalogFile {
    param([string]$RelativeSource, [string]$RelativeDestination = $RelativeSource)
    $source = Join-Path $catalogRoot $RelativeSource
    $target = Join-Path $destinationPath $RelativeDestination
    if (-not (Test-Path -LiteralPath $source)) {
        throw "Required catalogue file is missing: $RelativeSource"
    }
    $targetParent = Split-Path -Parent $target
    New-Item -ItemType Directory -Force -Path $targetParent | Out-Null
    Copy-Item -LiteralPath $source -Destination $target -Recurse -Force
}

function Copy-CatalogDirectoryContents {
    param([string]$RelativeSource)
    $source = Join-Path $catalogRoot $RelativeSource
    if (-not (Test-Path -LiteralPath $source)) {
        throw "Required catalogue directory is missing: $RelativeSource"
    }
    Get-ChildItem -LiteralPath $source -Force | Copy-Item -Destination $destinationPath -Recurse -Force
}

$commonFiles = @(
    ".ai\architecture.md",
    ".ai\api-guidelines.md",
    ".ai\security.md",
    ".ai\governance.md",
    ".ai\business-rules.md",
    ".ai\domain-model.md",
    ".ai\glossary.md",
    ".ai\tooling-policy.md",
    ".ai\version-control-policy.md",
    ".github\pull_request_template.md",
    "docs\adr\0000-template.md",
    "docs\threat-model-template.md",
    "docs\definition-of-done.md"
)
foreach ($file in $commonFiles) {
    Copy-CatalogFile $file
}

foreach ($file in @("project.md", "coding-standards.md", "testing.md", "dependencies.md")) {
    Copy-CatalogFile ".ai\profiles\$Profile\$file" ".ai\$file"
}

if ($profileConfig.includeFrontendStandards) {
    Copy-CatalogFile ".ai\frontend-standards.md"
}

foreach ($skill in $profileConfig.recommendedSkills) {
    Copy-CatalogFile "skills\$skill"
}

if ($null -ne $profileConfig.templatePath -and -not [string]::IsNullOrWhiteSpace($profileConfig.templatePath)) {
    Copy-CatalogDirectoryContents $profileConfig.templatePath
    $envExample = Join-Path $destinationPath ".env.example"
    $envFile = Join-Path $destinationPath ".env"
    if ((Test-Path -LiteralPath $envExample) -and -not (Test-Path -LiteralPath $envFile)) {
        Copy-Item -LiteralPath $envExample -Destination $envFile -Force
    }
}

if ($profileConfig.includeJavaAssets) {
    foreach ($asset in @("hooks", ".github\workflows\security.yml")) {
        Copy-CatalogFile $asset
    }
    Copy-CatalogFile "scripts\verify.ps1"
    Copy-CatalogFile "scripts\verify.sh"
}

$maturity = if ($profileConfig.PSObject.Properties.Name -contains "maturity") { $profileConfig.maturity } else { "unknown" }
$maturityNote = if ($maturity -eq "scaffold") {
    "This profile is scaffold maturity: standards context only. Add build files, tests, CI and skills before treating verification as executable."
} else {
    "This profile is runnable maturity: use the included template or example, skills and verification baseline."
}

$activeProfile = @"
# Active Engineering Profile

- Profile: `$Profile`
- Description: $($profileConfig.displayName)
- Category: $($profileConfig.category)
- Maturity: `$maturity`
- Verification baseline: `$($profileConfig.verification)`

$maturityNote

This file was generated from the AI Engineering Starter Kit catalogue.
Tailor `.ai/project.md`, business rules, domain model and ownership before implementation.
"@
New-Item -ItemType Directory -Force -Path (Join-Path $destinationPath ".ai") | Out-Null
Set-Content -LiteralPath (Join-Path $destinationPath ".ai\active-profile.md") -Value $activeProfile -Encoding utf8

$skillList = if (@($profileConfig.recommendedSkills).Count -gt 0) {
    ($profileConfig.recommendedSkills | ForEach-Object { "- ``$_``" }) -join "`n"
} else {
    "- No stack-specific skills are bundled yet. Create or install skills that load the active ``.ai/*.md`` context."
}

$skillsContext = @"
# Reusable AI Skills

Active profile: ``$Profile``.

Installed stack-specific skills:

$skillList

Every installed skill must locate the repository root and read ``AGENTS.md`` plus the applicable active
``.ai/*.md`` files before acting. Keep product and language facts in repository context rather than copying
them into skill procedures. Every implementation workflow must report verification evidence and every
generated test must include a meaningful outcome assertion.

Skills must follow ``.ai/tooling-policy.md``: use context-approved libraries/tools; when no choice is
documented, ask before adding one; and update context plus manifests/lockfiles/CI when an approved choice
becomes an ongoing project standard.

All skills must obey ``.ai/version-control-policy.md``. They may inspect Git but must never stage, commit,
push, change branches, rewrite history or open/merge a pull request. A human performs those actions manually.
"@
Set-Content -LiteralPath (Join-Path $destinationPath ".ai\skills.md") -Value $skillsContext -Encoding utf8

$projectContextFileName = "$ProjectName.md"
$projectContext = @"
# $ProjectName

Product-specific AI context for this repository. Enrich this file as the product evolves.
Keep secrets, production credentials and client data out of this file.

## Purpose

TODO: one short paragraph describing what this product does and who it serves.

## Scope

- In scope: TODO
- Out of scope: TODO

## AI working notes

- Preferred approach: TODO (for example smallest vertical slice, API-first, etc.)
- Important constraints: TODO (for example no breaking public API, no new dependencies without approval)
- Systems and integrations: TODO
- Data classification: TODO (for example internal / confidential)

## Open decisions

- TODO

## References

- Active stack profile: see ``.ai/project.md`` and ``.ai/active-profile.md``
- Business rules: ``.ai/business-rules.md``
- Domain model: ``.ai/domain-model.md``
"@
Set-Content -LiteralPath (Join-Path $destinationPath $projectContextFileName) -Value $projectContext -Encoding utf8

$agentsMd = @"
# Repository Instructions for AI Agents

Before changing code, read these files completely:

1. ``$projectContextFileName`` - product-specific purpose, scope and AI notes for this repository
2. ``AGENTS.md`` (this file)
3. ``.ai/project.md``, ``.ai/architecture.md``, ``.ai/coding-standards.md``, ``.ai/security.md``, and ``.ai/testing.md``
4. Other applicable ``.ai/*.md`` files for the task (API, business rules, domain model, dependencies, tooling, governance)

Make the smallest coherent change. Never weaken quality gates, delete tests to make a build pass,
invent requirements, expose secrets, or change a public API without calling it out.
Run the closest relevant checks, report what ran, and identify anything not verified.
All generated tests require at least one meaningful state or value assertion.

For work inside a nested application or package, locate and read the nearest applicable ``AGENTS.md`` and
``.ai`` context in addition to the repository root. More specific guidance applies within its subtree but
must not weaken root governance or security controls. Browser/UI work must also read
``.ai/frontend-standards.md`` when present.

Before selecting or adding any library, framework or tool, read ``.ai/tooling-policy.md`` and
``.ai/dependencies.md``. Use the context-specified choice. If no choice is specified, stop and ask the user
before adding one. When an approved choice becomes an ongoing project standard, update the relevant ``.ai``
context, dependency manifest, lockfile and verification configuration in the same change.

Read ``.ai/version-control-policy.md``. Never stage, commit, amend, tag, push, force-push, change branches,
rewrite history, open a pull request, approve, merge or publish repository changes. This remains prohibited
even when explicitly requested. Leave changes uncommitted and hand them to a human for inspection and manual
action through Git or an approved IDE.

Keep durable product facts in ``$projectContextFileName`` and ``.ai/*.md``. Do not bury project-specific
requirements only inside chat history or skill bodies.
"@
Set-Content -LiteralPath (Join-Path $destinationPath "AGENTS.md") -Value $agentsMd -Encoding utf8

$containerSection = if ($null -ne $profileConfig.templatePath -and -not [string]::IsNullOrWhiteSpace($profileConfig.templatePath)) {
@"

## Containers and Dev Containers

This project includes Docker and Dev Container assets:

- ``Dockerfile`` - multistage image with pinned tool packages and a ``development`` stage
  (lint/test tooling baked in) plus a minimal ``production`` stage
- ``compose.yml`` - builds ``target: development`` for app + PostgreSQL
- ``.env.example`` - local defaults (copied to ``.env`` at generation; do not commit secrets)
- ``.devcontainer/`` - attaches to the project development image (not a generic language image)

```powershell
copy .env.example .env
docker compose up --build
```

Inside the development container, run the stack verification commands (for example ``ruff`` /
``mypy`` / ``pytest``, ``mvn verify``, or ``dotnet format`` / ``dotnet test``).
Open the folder in a Dev Container to develop against Compose PostgreSQL with tooling already present.
"@
} else {
@"

## Containers

This scaffold profile does not yet ship Docker/Dev Container assets. Add a Dockerfile, Compose file
and ``.devcontainer`` before treating local containers as a project standard.
"@
}

$readme = @"
# $ProjectName

$($profileConfig.displayName) generated from the AI Engineering Starter Kit.

## Before development

1. Enrich ``$projectContextFileName`` with product purpose, scope and AI working notes.
2. Replace the starter content in ``.ai/project.md``, ``.ai/business-rules.md`` and ``.ai/domain-model.md``.
3. Record owners, data classification, external systems and deployment constraints.
4. Confirm verification, hooks and CI run for this stack.
5. Review ``.env`` values; keep secrets out of Git.
6. Configure CODEOWNERS, CI secrets and protected-branch rules.
7. Run a representative test containing a meaningful outcome assertion.

## Product AI context

``$projectContextFileName`` is the product-specific Markdown context file for this repository.
Agents must read it before changing code. Keep enriching it as requirements become clearer.

## Verification baseline

```text
$($profileConfig.verification)
```

## Included skills

$skillList
$containerSection
## Governance

Read ``AGENTS.md``, ``$projectContextFileName``, and all applicable ``.ai/*.md`` files before changing code.
AI output is untrusted until inspected, tested and approved by an accountable human.
"@
Set-Content -LiteralPath (Join-Path $destinationPath "README.md") -Value $readme -Encoding utf8

$generationRecord = [ordered]@{
    schemaVersion = 1
    projectName = $ProjectName
    projectContextFile = $projectContextFileName
    profile = $Profile
    category = $profileConfig.category
    maturity = $maturity
    destination = $destinationPath
    sourceCatalogue = "AI Engineering Starter Kit"
    generatedAtUtc = [DateTime]::UtcNow.ToString("o")
}
$generationRecord | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $destinationPath ".ai\generation.json") -Encoding utf8

Write-Output "Created '$ProjectName' with profile '$Profile' at $destinationPath"
Write-Output "Product AI context file: $projectContextFileName"
Write-Output "Next: enrich $projectContextFileName, tailor .ai context, then verify. A human must inspect, stage, commit and push."
