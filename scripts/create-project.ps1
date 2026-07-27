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

    [Parameter(ParameterSetName = "Create", Mandatory = $false)]
    [string]$ConfigPath,

    [Parameter(ParameterSetName = "Create", Mandatory = $false)]
    [string]$Description,

    [Parameter(ParameterSetName = "Create", Mandatory = $false)]
    [string]$EntityName,

    [Parameter(ParameterSetName = "Create", Mandatory = $false)]
    [string]$TechnicalOwner,

    [Parameter(ParameterSetName = "Create", Mandatory = $false)]
    [string]$BusinessOwner,

    [Parameter(ParameterSetName = "Create", Mandatory = $false)]
    [string]$RiskClassification,

    [Parameter(ParameterSetName = "Create", Mandatory = $false)]
    [string]$DataClassification,

    [Parameter(ParameterSetName = "Create", Mandatory = $false)]
    [string]$ProductionCriticality,

    [Parameter(ParameterSetName = "Create", Mandatory = $false)]
    [string]$DeploymentTarget,

    [Parameter(ParameterSetName = "Create", Mandatory = $false)]
    [string]$JavaGroupId,

    [Parameter(ParameterSetName = "Create", Mandatory = $false)]
    [string]$JavaArtifactId,

    [Parameter(ParameterSetName = "Create", Mandatory = $false)]
    [string]$JavaBasePackage,

    [Parameter(ParameterSetName = "Create", Mandatory = $false)]
    [string]$PythonPackageName,

    [Parameter(ParameterSetName = "Create", Mandatory = $false)]
    [string]$CsharpRootNamespace,

    [Parameter(ParameterSetName = "Create", Mandatory = $false)]
    [string]$CsharpProjectName,

    [Parameter(ParameterSetName = "Create", Mandatory = $false)]
    [ValidateSet("draft", "production")]
    [string]$ValidationMode = "draft",

    [Parameter(ParameterSetName = "List", Mandatory = $true)]
    [switch]$ListProfiles
)

$ErrorActionPreference = "Stop"
$catalogRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
. (Join-Path $PSScriptRoot "lib\ProjectConfig.ps1")
. (Join-Path $PSScriptRoot "lib\RewriteIdentity.ps1")

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
$maturity = if ($profileConfig.PSObject.Properties.Name -contains "maturity") { $profileConfig.maturity } else { "unknown" }

# Load or build project config (fail closed).
if ($ConfigPath) {
    if (-not (Test-Path -LiteralPath $ConfigPath)) {
        throw "ConfigPath not found: $ConfigPath"
    }
    $projectConfig = ConvertFrom-SimpleYaml -Path $ConfigPath
    if ([string]$projectConfig.projectName -eq 'PLACEHOLDER_PROJECT_NAME') {
        $projectConfig.projectName = $ProjectName
    }
    if ($projectConfig.identity.java.artifactId -eq 'PLACEHOLDER_ARTIFACT') {
        $projectConfig.identity.java.artifactId = $ProjectName.ToLowerInvariant()
    }
    if ($projectConfig.identity.python.distributionName -eq 'PLACEHOLDER_ARTIFACT') {
        $projectConfig.identity.python.distributionName = $ProjectName.ToLowerInvariant()
    }
} else {
    $missing = @()
    if ([string]::IsNullOrWhiteSpace($Description)) { $missing += 'Description' }
    if ([string]::IsNullOrWhiteSpace($EntityName)) { $missing += 'EntityName' }
    if ([string]::IsNullOrWhiteSpace($TechnicalOwner)) { $missing += 'TechnicalOwner' }
    if ([string]::IsNullOrWhiteSpace($BusinessOwner)) { $missing += 'BusinessOwner' }
    if ([string]::IsNullOrWhiteSpace($RiskClassification)) { $missing += 'RiskClassification' }
    if ([string]::IsNullOrWhiteSpace($DataClassification)) { $missing += 'DataClassification' }
    if ([string]::IsNullOrWhiteSpace($ProductionCriticality)) { $missing += 'ProductionCriticality' }
    if ([string]::IsNullOrWhiteSpace($DeploymentTarget)) { $missing += 'DeploymentTarget' }
    if ($missing.Count -gt 0) {
        throw ("Without -ConfigPath, these governance fields are required (no silent defaults): " + ($missing -join ', '))
    }
    $projectConfig = New-ProjectConfigFromParameters `
        -ProjectName $ProjectName `
        -Description $Description `
        -EntityName $EntityName `
        -TechnicalOwner $TechnicalOwner `
        -BusinessOwner $BusinessOwner `
        -RiskClassification $RiskClassification `
        -DataClassification $DataClassification `
        -ProductionCriticality $ProductionCriticality `
        -DeploymentTarget $DeploymentTarget `
        -JavaGroupId $JavaGroupId `
        -JavaArtifactId $JavaArtifactId `
        -JavaBasePackage $JavaBasePackage `
        -PythonPackageName $PythonPackageName `
        -CsharpRootNamespace $CsharpRootNamespace `
        -CsharpProjectName $CsharpProjectName
}
Test-ProjectConfigObject -Config $projectConfig -ExpectedProjectName $ProjectName
$derived = Get-DerivedIdentityNames -Config $projectConfig

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
    $excludeNames = @(
        '.pytest_cache', '.mypy_cache', '.ruff_cache', '.venv', 'venv',
        'target', 'bin', 'obj', 'TestResults', 'node_modules',
        '.coverage', 'htmlcov', '__pycache__', '.idea', '.vs'
    )
    function Copy-FilteredTree {
        param([string]$FromDir, [string]$ToDir)
        New-Item -ItemType Directory -Force -Path $ToDir | Out-Null
        Get-ChildItem -LiteralPath $FromDir -Force | ForEach-Object {
            if ($excludeNames -contains $_.Name) { return }
            $target = Join-Path $ToDir $_.Name
            if ($_.PSIsContainer) {
                Copy-FilteredTree -FromDir $_.FullName -ToDir $target
            } else {
                Copy-Item -LiteralPath $_.FullName -Destination $target -Force
            }
        }
    }
    Copy-FilteredTree -FromDir $source -ToDir $destinationPath
}

function Set-UnixExecutable {
    param([string[]]$RelativePaths)
    foreach ($rel in $RelativePaths) {
        $path = Join-Path $destinationPath $rel
        if (-not (Test-Path -LiteralPath $path)) { continue }
        if (Get-Command chmod -ErrorAction SilentlyContinue) {
            & chmod +x -- $path
        }
    }
}

function Write-Utf8NoBomFile {
    param([string]$Path, [string]$Content)
    $parent = Split-Path -Parent $Path
    if ($parent) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

function Expand-GovernanceTemplate {
    param([string]$SourceRelative, [string]$TargetRelative)
    $source = Join-Path $catalogRoot $SourceRelative
    $content = [System.IO.File]::ReadAllText($source)
    $content = $content.
        Replace('{{PROJECT_NAME}}', $ProjectName).
        Replace('{{TECHNICAL_OWNER}}', [string]$projectConfig.owners.technical).
        Replace('{{BUSINESS_OWNER}}', [string]$projectConfig.owners.business).
        Replace('{{RISK_CLASSIFICATION}}', [string]$projectConfig.riskClassification).
        Replace('{{DATA_CLASSIFICATION}}', [string]$projectConfig.dataClassification).
        Replace('{{PRODUCTION_CRITICALITY}}', [string]$projectConfig.productionCriticality).
        Replace('{{DEPLOYMENT_TARGET}}', [string]$projectConfig.deploymentTarget)
    Write-Utf8NoBomFile -Path (Join-Path $destinationPath $TargetRelative) -Content $content
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
    ".ai\prompts.md",
    ".ai\project-config.schema.yml",
    ".gitignore",
    ".gitattributes",
    ".github\pull_request_template.md",
    "docs\adr\0000-template.md",
    "docs\threat-model-template.md",
    "docs\definition-of-done.md",
    "docs\upgrades\compatibility-matrix.md",
    "docs\upgrades\migration-guide.md"
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

Copy-CatalogFile "CLAUDE.md"
Copy-CatalogFile ".github\copilot-instructions.md"
Copy-CatalogFile ".cursor\rules\standards.mdc"

if ($null -ne $profileConfig.templatePath -and -not [string]::IsNullOrWhiteSpace($profileConfig.templatePath)) {
    Copy-CatalogDirectoryContents $profileConfig.templatePath
    $envExample = Join-Path $destinationPath ".env.example"
    $envFile = Join-Path $destinationPath ".env"
    if ((Test-Path -LiteralPath $envExample) -and -not (Test-Path -LiteralPath $envFile)) {
        Copy-Item -LiteralPath $envExample -Destination $envFile -Force
    }
}

if ($maturity -eq "runnable") {
    Copy-CatalogFile "hooks\$Profile\pre-commit" "hooks\pre-commit"
    Copy-CatalogFile "hooks\$Profile\pre-push" "hooks\pre-push"
    Copy-CatalogFile "scripts\install-hooks.ps1"
    Copy-CatalogFile "scripts\install-hooks.sh"
    Copy-CatalogFile ".github\workflows\security.yml"
    Copy-CatalogFile "config\semgrep.yml"
    Copy-CatalogFile "scripts\check-exceptions.ps1"
    if ($Profile -eq "java") {
        Copy-CatalogFile "scripts\verify.ps1"
        Copy-CatalogFile "scripts\verify.sh"
        if (Test-Path -LiteralPath (Join-Path $destinationPath "mvnw")) {
            Set-UnixExecutable -RelativePaths @("mvnw")
        }
    }
    Set-UnixExecutable -RelativePaths @(
        "hooks\pre-commit",
        "hooks\pre-push",
        "scripts\install-hooks.sh",
        "scripts\check-exceptions.ps1"
    )
}

# Governance artifacts from templates + config
Expand-GovernanceTemplate "templates\governance\CODEOWNERS" "CODEOWNERS"
Expand-GovernanceTemplate "templates\governance\SECURITY.md" "SECURITY.md"
Expand-GovernanceTemplate "templates\governance\docs\support.md" "docs\support.md"
Expand-GovernanceTemplate "templates\governance\docs\approval-matrix.md" "docs\approval-matrix.md"
Expand-GovernanceTemplate "templates\governance\docs\exceptions\template.md" "docs\exceptions\template.md"
Expand-GovernanceTemplate "templates\governance\docs\github-rulesets.md" "docs\github-rulesets.md"

Write-ProjectConfigYaml -Config $projectConfig -Path (Join-Path $destinationPath ".ai\project-config.yml")

# Rewrite sample identity for runnable templates
if ($null -ne $profileConfig.templatePath -and -not [string]::IsNullOrWhiteSpace($profileConfig.templatePath)) {
    Invoke-IdentityRewrite -ProjectRoot $destinationPath -Config $projectConfig -Profile $Profile
    Test-NoSampleIdentityLeft -ProjectRoot $destinationPath -Config $projectConfig
}

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
- Entity: $($projectConfig.entityName)
- Owners: technical $($projectConfig.owners.technical); business $($projectConfig.owners.business)

$maturityNote

This file was generated from the AI Engineering Starter Kit catalogue.
Product identity lives in ``.ai/project-config.yml``. Configure GitHub rulesets per ``docs/github-rulesets.md``.
"@
Write-Utf8NoBomFile -Path (Join-Path $destinationPath ".ai\active-profile.md") -Content $activeProfile

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

Every installed skill must locate the repository root, read ``AGENTS.md``, discover the product context
filename from ``.ai/generation.json`` (falling back to the root ``$ProjectName.md`` file), read
``.ai/project-config.yml``, and read that product context plus the applicable active ``.ai/*.md`` files
before acting. Keep product and language facts in repository context rather than copying them into skill
procedures. Every implementation workflow must report verification evidence and every generated test must
include a meaningful outcome assertion.

Skills must follow ``.ai/tooling-policy.md`` and ``.ai/version-control-policy.md``. Never stage, commit,
push, change branches, rewrite history or open/merge a pull request.
"@
Write-Utf8NoBomFile -Path (Join-Path $destinationPath ".ai\skills.md") -Content $skillsContext

$projectContextFileName = "$ProjectName.md"
$projectContext = @"
# $ProjectName

Product-specific AI context for this repository. Enrich this file as the product evolves.
Keep secrets, production credentials and client data out of this file.
Validation mode at generation: ``$ValidationMode``.

## Purpose

$($projectConfig.description)

## Scope

- In scope: core ``$($projectConfig.entityName)`` API and persistence for ``$($projectConfig.deploymentTarget)``
- Out of scope: (define before production validation)

## AI working notes

- Preferred approach: smallest vertical slice around ``$($projectConfig.entityName)``
- Important constraints: respect ``.ai/project-config.yml`` identity and ownership
- Systems and integrations: (define before production validation)
- Data classification: $($projectConfig.dataClassification)
- Risk classification: $($projectConfig.riskClassification)

## Open decisions

- (none recorded yet — clear or replace before production validation)

## References

- Product config: ``.ai/project-config.yml``
- Active stack profile: ``.ai/project.md`` and ``.ai/active-profile.md``
- Governance: ``SECURITY.md``, ``CODEOWNERS``, ``docs/approval-matrix.md``, ``docs/github-rulesets.md``
"@
if ($ValidationMode -eq 'draft') {
    $projectContext = @"
# $ProjectName

Product-specific AI context for this repository. Enrich this file as the product evolves.
Keep secrets, production credentials and client data out of this file.
Validation mode at generation: ``draft`` (TODOs allowed until production validation).

## Purpose

$($projectConfig.description)

## Scope

- In scope: core ``$($projectConfig.entityName)`` API and persistence for ``$($projectConfig.deploymentTarget)``
- Out of scope: TODO

## AI working notes

- Preferred approach: smallest vertical slice around ``$($projectConfig.entityName)``
- Important constraints: respect ``.ai/project-config.yml`` identity and ownership
- Systems and integrations: TODO
- Data classification: $($projectConfig.dataClassification)
- Risk classification: $($projectConfig.riskClassification)

## Open decisions

- TODO

## References

- Product config: ``.ai/project-config.yml``
- Active stack profile: ``.ai/project.md`` and ``.ai/active-profile.md``
- Governance: ``SECURITY.md``, ``CODEOWNERS``, ``docs/approval-matrix.md``, ``docs/github-rulesets.md``
"@
}Write-Utf8NoBomFile -Path (Join-Path $destinationPath $projectContextFileName) -Content $projectContext

foreach ($entrypoint in @("CLAUDE.md", ".github\copilot-instructions.md", ".cursor\rules\standards.mdc")) {
    $entrypointPath = Join-Path $destinationPath $entrypoint
    $entrypointContent = [System.IO.File]::ReadAllText($entrypointPath)
    $entrypointContent = $entrypointContent.Replace("<ProjectName>.md", $projectContextFileName)
    Write-Utf8NoBomFile -Path $entrypointPath -Content $entrypointContent
}

$agentsMd = @"
# Repository Instructions for AI Agents

Before changing code, read these files completely:

1. ``$projectContextFileName`` - product-specific purpose, scope and AI notes
2. ``.ai/project-config.yml`` - identity, owners, classifications and deployment target
3. ``AGENTS.md`` (this file)
4. ``.ai/project.md``, ``.ai/architecture.md``, ``.ai/coding-standards.md``, ``.ai/security.md``, and ``.ai/testing.md``
5. Other applicable ``.ai/*.md`` files for the task

Make the smallest coherent change. Never weaken quality gates, delete tests to make a build pass,
invent requirements, expose secrets, or change a public API without calling it out.
Run the closest relevant checks, report what ran, and identify anything not verified.
All generated tests require at least one meaningful state or value assertion.

Before selecting or adding any library, framework or tool, read ``.ai/tooling-policy.md`` and
``.ai/dependencies.md``. Use the context-specified choice. If no choice is specified, stop and ask the user
before adding one.

Read ``.ai/version-control-policy.md``. Never stage, commit, amend, tag, push, force-push, change branches,
rewrite history, open a pull request, approve, merge or publish repository changes. Leave changes
uncommitted for a human.

Keep durable product facts in ``$projectContextFileName``, ``.ai/project-config.yml`` and ``.ai/*.md``.
"@
Write-Utf8NoBomFile -Path (Join-Path $destinationPath "AGENTS.md") -Content $agentsMd

$containerSection = if ($null -ne $profileConfig.templatePath -and -not [string]::IsNullOrWhiteSpace($profileConfig.templatePath)) {
@"

## Containers and Dev Containers

This project includes Docker and Dev Container assets. Database name: ``$($derived.DatabaseName)``.

```powershell
copy .env.example .env
docker compose up --build
```
"@
} else {
@"

## Containers

This scaffold profile does not yet ship Docker/Dev Container assets.
"@
}

$readme = @"
# $ProjectName

$($profileConfig.displayName) generated from the AI Engineering Starter Kit.

## Before development

1. Review ``.ai/project-config.yml`` (identity, owners, classifications).
2. Enrich ``$projectContextFileName``.
3. Configure GitHub rulesets using ``docs/github-rulesets.md`` (human-only).
4. For runnable profiles, run ``scripts/install-hooks.ps1`` or ``scripts/install-hooks.sh``.
5. Review ``.env``; keep secrets out of Git.
6. Confirm ``CODEOWNERS`` and ``SECURITY.md`` contacts.
7. Run the verification baseline below.

## Verification baseline

```text
$($profileConfig.verification)
```

## Included skills

$skillList
$containerSection
## Governance

Read ``AGENTS.md``, ``$projectContextFileName``, ``.ai/project-config.yml``, ``SECURITY.md``,
``docs/approval-matrix.md`` and ``docs/github-rulesets.md`` before changing code.
"@
Write-Utf8NoBomFile -Path (Join-Path $destinationPath "README.md") -Content $readme

$kitVersionPath = Join-Path $catalogRoot "VERSION"
$kitVersion = if (Test-Path -LiteralPath $kitVersionPath) {
    (Get-Content -LiteralPath $kitVersionPath -Raw).Trim()
} else {
    "0.1.0"
}

$generationRecord = [ordered]@{
    schemaVersion = 2
    projectName = $ProjectName
    projectContextFile = $projectContextFileName
    projectConfigFile = ".ai/project-config.yml"
    profile = $Profile
    category = $profileConfig.category
    maturity = $maturity
    entityName = [string]$projectConfig.entityName
    validationMode = $ValidationMode
    starterKitVersion = $kitVersion
    profileVersion = "1"
    destination = $destinationPath
    sourceCatalogue = "AI Engineering Starter Kit"
    generatedAtUtc = [DateTime]::UtcNow.ToString("o")
}
$json = $generationRecord | ConvertTo-Json
Write-Utf8NoBomFile -Path (Join-Path $destinationPath ".ai\generation.json") -Content $json

Write-Output "Created '$ProjectName' with profile '$Profile' at $destinationPath"
Write-Output "Product AI context file: $projectContextFileName"
Write-Output "Product config: .ai/project-config.yml (entity $($projectConfig.entityName))"
Write-Output "Next: configure GitHub rulesets, install hooks, verify. A human must inspect, stage, commit and push."
