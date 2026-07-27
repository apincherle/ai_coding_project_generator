param(
    [Parameter(Mandatory = $true)]
    [string]$Path,

    [Parameter(Mandatory = $false)]
    [ValidateSet("draft", "production")]
    [string]$ValidationMode
)

$ErrorActionPreference = "Stop"
$scriptRoot = $PSScriptRoot
. (Join-Path $scriptRoot "lib\ProjectConfig.ps1")
. (Join-Path $scriptRoot "lib\RewriteIdentity.ps1")

$projectRoot = (Resolve-Path -LiteralPath $Path).Path
$recordPath = Join-Path $projectRoot ".ai\generation.json"
if (-not (Test-Path -LiteralPath $recordPath)) {
    throw "Not a generated project: .ai/generation.json is missing."
}
$record = Get-Content -LiteralPath $recordPath -Raw | ConvertFrom-Json

$required = @(
    "AGENTS.md",
    "CLAUDE.md",
    ".cursor\rules\standards.mdc",
    ".github\copilot-instructions.md",
    ".gitignore",
    ".gitattributes",
    "README.md",
    "CODEOWNERS",
    "SECURITY.md",
    "docs\support.md",
    "docs\approval-matrix.md",
    "docs\exceptions\template.md",
    "docs\github-rulesets.md",
    "docs\upgrades\compatibility-matrix.md",
    "docs\upgrades\migration-guide.md",
    ".ai\active-profile.md",
    ".ai\project.md",
    ".ai\architecture.md",
    ".ai\coding-standards.md",
    ".ai\testing.md",
    ".ai\security.md",
    ".ai\governance.md",
    ".ai\dependencies.md",
    ".ai\tooling-policy.md",
    ".ai\version-control-policy.md",
    ".ai\skills.md",
    ".ai\prompts.md",
    ".ai\project-config.yml",
    ".ai\project-config.schema.yml",
    ".github\pull_request_template.md"
)
foreach ($relative in $required) {
    if (-not (Test-Path -LiteralPath (Join-Path $projectRoot $relative))) {
        throw "Required generated file is missing: $relative"
    }
}

$projectConfig = ConvertFrom-SimpleYaml -Path (Join-Path $projectRoot ".ai\project-config.yml")
Test-ProjectConfigObject -Config $projectConfig -ExpectedProjectName ([string]$record.projectName)

$projectContextFile = if ($record.PSObject.Properties.Name -contains "projectContextFile" -and $record.projectContextFile) {
    [string]$record.projectContextFile
} else {
    "$($record.projectName).md"
}
if (-not (Test-Path -LiteralPath (Join-Path $projectRoot $projectContextFile))) {
    throw "Product AI context file is missing: $projectContextFile"
}

$versionControlPolicy = Get-Content -LiteralPath (Join-Path $projectRoot ".ai\version-control-policy.md") -Raw
if ($versionControlPolicy -notmatch "must never" -or $versionControlPolicy -notmatch "Push or force-push") {
    throw "Human-only version-control policy is incomplete."
}
$agentInstructions = Get-Content -LiteralPath (Join-Path $projectRoot "AGENTS.md") -Raw
if ($agentInstructions -notmatch "Never stage, commit") {
    throw "AGENTS.md does not enforce human-only commit and push."
}
if ($agentInstructions -notmatch [regex]::Escape($projectContextFile)) {
    throw "AGENTS.md does not require reading product context file '$projectContextFile'."
}
if ($agentInstructions -notmatch "project-config\.yml") {
    throw "AGENTS.md does not require reading .ai/project-config.yml."
}
foreach ($entrypoint in @("CLAUDE.md", ".cursor\rules\standards.mdc", ".github\copilot-instructions.md")) {
    $entrypointContent = Get-Content -LiteralPath (Join-Path $projectRoot $entrypoint) -Raw
    if ($entrypointContent -notmatch "AGENTS\.md" -or $entrypointContent -notmatch [regex]::Escape($projectContextFile)) {
        throw "AI entrypoint '$entrypoint' does not direct the assistant to AGENTS.md and '$projectContextFile'."
    }
}

$gitignore = Get-Content -LiteralPath (Join-Path $projectRoot ".gitignore") -Raw
foreach ($requiredIgnore in @(".env", "target/", ".venv/", "bin/", "obj/", ".coverage")) {
    if ($gitignore -notmatch [regex]::Escape($requiredIgnore)) {
        throw ".gitignore is missing required protection: $requiredIgnore"
    }
}

$skillsContext = Get-Content -LiteralPath (Join-Path $projectRoot ".ai\skills.md") -Raw
if ($skillsContext -notmatch [regex]::Escape($projectContextFile) -and $skillsContext -notmatch "generation\.json") {
    throw ".ai/skills.md does not require loading product context."
}

$productContext = Get-Content -LiteralPath (Join-Path $projectRoot $projectContextFile) -Raw
if ($productContext -notmatch "(?m)^#\s+" -or $productContext -notmatch "Purpose") {
    throw "Product AI context file '$projectContextFile' is missing required minimal sections."
}

$effectiveMode = $ValidationMode
if ([string]::IsNullOrWhiteSpace($effectiveMode)) {
    if ($record.PSObject.Properties.Name -contains 'validationMode' -and $record.validationMode) {
        $effectiveMode = [string]$record.validationMode
    } else {
        $effectiveMode = 'draft'
    }
}
if ($effectiveMode -eq 'production') {
    if ($productContext -match '(?i)\bTODO\b') {
        throw "Production validation rejected TODO markers in product context file '$projectContextFile'."
    }
    if ($productContext -match '(?i)\bchangeme\b' -or $productContext -match '(?i)\bREPLACE_ME\b') {
        throw "Production validation rejected placeholder text in product context file '$projectContextFile'."
    }
}

$prTemplate = Get-Content -LiteralPath (Join-Path $projectRoot ".github\pull_request_template.md") -Raw
foreach ($section in @("Security", "Architecture", "AI usage", "Migration", "Rollback")) {
    if ($prTemplate -notmatch [regex]::Escape($section)) {
        throw "PR template missing section: $section"
    }
}

if (Test-Path -LiteralPath (Join-Path $projectRoot ".ai\profiles")) {
    throw "Generated project contains the source profile catalogue."
}

$javaOnly = @("pom.xml", "config\checkstyle.xml", "skills\create-spring-feature")
if ($record.profile -ne "java") {
    foreach ($relative in $javaOnly) {
        if (Test-Path -LiteralPath (Join-Path $projectRoot $relative)) {
            throw "Profile '$($record.profile)' contains Java-only asset: $relative"
        }
    }
}

$containerFiles = @(
    "Dockerfile",
    "compose.yml",
    ".env.example",
    ".dockerignore",
    ".devcontainer\devcontainer.json",
    ".devcontainer\compose.yml"
)

$derived = Get-DerivedIdentityNames -Config $projectConfig
$javaPkgPath = ([string]$projectConfig.identity.java.basePackage).Replace('.', '\')
$pyPkg = [string]$projectConfig.identity.python.packageName
$csProj = [string]$projectConfig.identity.csharp.projectName
$csSol = [string]$projectConfig.identity.csharp.solutionName

if ($record.profile -eq "java") {
    $javaMain = "src\main\java\$javaPkgPath\$($derived.EntityPascal)ApiApplication.java"
    foreach ($relative in @("pom.xml", $javaMain, ".github\workflows\build.yml", "skills\create-spring-feature") + $containerFiles) {
        if (-not (Test-Path -LiteralPath (Join-Path $projectRoot $relative))) {
            throw "Java project is missing: $relative"
        }
    }
    Test-NoSampleIdentityLeft -ProjectRoot $projectRoot -Config $projectConfig
}

if ($record.profile -eq "python") {
    foreach ($relative in @("pyproject.toml", "uv.lock", "src\$pyPkg\main.py", "tests\test_api.py", "skills\create-python-feature") + $containerFiles) {
        if (-not (Test-Path -LiteralPath (Join-Path $projectRoot $relative))) {
            throw "Python project is missing: $relative"
        }
    }
    Test-NoSampleIdentityLeft -ProjectRoot $projectRoot -Config $projectConfig
}

if ($record.profile -eq "csharp") {
    foreach ($relative in @(
        "$csSol.slnx",
        "src\$csProj\$csProj.csproj",
        "tests\$csProj.Tests\CustomerServiceTests.cs",
        "skills\create-dotnet-feature"
    ) + $containerFiles) {
        # test file may have been renamed
        $altTest = "tests\$csProj.Tests\$($derived.EntityPascal)ServiceTests.cs"
        if ($relative -like '*CustomerServiceTests.cs') {
            if (-not (Test-Path -LiteralPath (Join-Path $projectRoot $relative)) -and
                -not (Test-Path -LiteralPath (Join-Path $projectRoot $altTest))) {
                throw "C# project is missing test file for $($derived.EntityPascal)Service"
            }
            continue
        }
        if (-not (Test-Path -LiteralPath (Join-Path $projectRoot $relative))) {
            throw "C# project is missing: $relative"
        }
    }
    Test-NoSampleIdentityLeft -ProjectRoot $projectRoot -Config $projectConfig
}

if ($record.maturity -eq "runnable") {
    foreach ($relative in @(
        "hooks\pre-commit",
        "hooks\pre-push",
        "scripts\install-hooks.ps1",
        "scripts\install-hooks.sh",
        ".github\workflows\security.yml",
        "config\semgrep.yml",
        "scripts\check-exceptions.ps1"
    )) {
        if (-not (Test-Path -LiteralPath (Join-Path $projectRoot $relative))) {
            throw "Runnable profile is missing required enforcement asset: $relative"
        }
    }
}

$frontendProfiles = @("react-typescript", "nextjs-typescript")
$frontendFile = Join-Path $projectRoot ".ai\frontend-standards.md"
if ($record.profile -in $frontendProfiles) {
    if (-not (Test-Path -LiteralPath $frontendFile)) {
        throw "Frontend profile is missing .ai/frontend-standards.md"
    }
} elseif (Test-Path -LiteralPath $frontendFile) {
    throw "Non-frontend profile contains .ai/frontend-standards.md"
}

Write-Output "Generated project is valid: $($record.projectName) [$($record.profile)]"
