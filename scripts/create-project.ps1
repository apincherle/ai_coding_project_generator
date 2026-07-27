[CmdletBinding(DefaultParameterSetName = "Create")]
param(
    [Parameter(ParameterSetName = "Create", Mandatory = $true)]
    [string]$Profile,

    [Parameter(ParameterSetName = "Create", Mandatory = $true)]
    [ValidatePattern("^[A-Za-z0-9][A-Za-z0-9._-]*$")]
    [string]$ProjectName,

    [Parameter(ParameterSetName = "Create", Mandatory = $true)]
    [string]$Destination,

    [Parameter(ParameterSetName = "Create")]
    [switch]$IncludeJavaExample,

    [Parameter(ParameterSetName = "List", Mandatory = $true)]
    [switch]$ListProfiles
)

$ErrorActionPreference = "Stop"
$catalogRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$manifestPath = Join-Path $catalogRoot "manifests\profiles.json"
$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json

if ($ListProfiles) {
    $manifest.profiles.PSObject.Properties | ForEach-Object {
        [PSCustomObject]@{
            Profile = $_.Name
            Description = $_.Value.displayName
            Category = $_.Value.category
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

$destinationPath = [System.IO.Path]::GetFullPath($Destination)
if (Test-Path -LiteralPath $destinationPath) {
    $existing = @(Get-ChildItem -LiteralPath $destinationPath -Force)
    if ($existing.Count -gt 0) {
        throw "Destination must not exist or must be empty: $destinationPath"
    }
} else {
    New-Item -ItemType Directory -Path $destinationPath | Out-Null
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
    "AGENTS.md",
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
}

if ($profileConfig.includeJavaAssets) {
    foreach ($asset in @("config", "hooks", ".github\workflows\build.yml", ".github\workflows\security.yml")) {
        Copy-CatalogFile $asset
    }
    Copy-CatalogFile "scripts\verify.ps1"
    Copy-CatalogFile "scripts\verify.sh"
    if ($IncludeJavaExample) {
        Copy-CatalogFile "examples\spring-api"
    }
} elseif ($IncludeJavaExample) {
    throw "-IncludeJavaExample is valid only with the java profile."
}

$activeProfile = @"
# Active Engineering Profile

- Profile: `$Profile`
- Description: $($profileConfig.displayName)
- Category: $($profileConfig.category)
- Verification baseline: `$($profileConfig.verification)`

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

$readme = @"
# $ProjectName

$($profileConfig.displayName) generated from the AI Engineering Starter Kit.

## Before development

1. Replace the starter content in ``.ai/project.md``, ``.ai/business-rules.md`` and ``.ai/domain-model.md``.
2. Record owners, data classification, external systems and deployment constraints.
3. Add the stack-specific build files and make the verification baseline executable.
4. Configure CODEOWNERS, CI secrets and protected-branch rules.
5. Run a representative test containing a meaningful outcome assertion.

## Verification baseline

```text
$($profileConfig.verification)
```

## Included skills

$skillList

## Governance

Read ``AGENTS.md`` and all applicable ``.ai/*.md`` files before changing code.
AI output is untrusted until inspected, tested and approved by an accountable human.
"@
Set-Content -LiteralPath (Join-Path $destinationPath "README.md") -Value $readme -Encoding utf8

$generationRecord = [ordered]@{
    schemaVersion = 1
    projectName = $ProjectName
    profile = $Profile
    category = $profileConfig.category
    sourceCatalogue = "AI Engineering Starter Kit"
    generatedAtUtc = [DateTime]::UtcNow.ToString("o")
    includedJavaExample = [bool]$IncludeJavaExample
}
$generationRecord | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $destinationPath ".ai\generation.json") -Encoding utf8

Write-Output "Created '$ProjectName' with profile '$Profile' at $destinationPath"
Write-Output "Next: tailor context and verify the project. A human must inspect, stage, commit and push."
