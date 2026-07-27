param(
    [Parameter(Mandatory = $true)]
    [string]$Path
)

$ErrorActionPreference = "Stop"
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
    ".github\pull_request_template.md"
)
foreach ($relative in $required) {
    if (-not (Test-Path -LiteralPath (Join-Path $projectRoot $relative))) {
        throw "Required generated file is missing: $relative"
    }
}

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

if ($record.profile -eq "java") {
    foreach ($relative in @("pom.xml", "src\main\java\com\example\customer\CustomerApiApplication.java", ".github\workflows\build.yml", "skills\create-spring-feature") + $containerFiles) {
        if (-not (Test-Path -LiteralPath (Join-Path $projectRoot $relative))) {
            throw "Java project is missing: $relative"
        }
    }
}

if ($record.profile -eq "python") {
    foreach ($relative in @("pyproject.toml", "uv.lock", "src\customer_api\main.py", "tests\test_api.py", "skills\create-python-feature") + $containerFiles) {
        if (-not (Test-Path -LiteralPath (Join-Path $projectRoot $relative))) {
            throw "Python project is missing: $relative"
        }
    }
}

if ($record.profile -eq "csharp") {
    foreach ($relative in @("CustomerApi.slnx", "src\CustomerApi\CustomerApi.csproj", "tests\CustomerApi.Tests\CustomerServiceTests.cs", "skills\create-dotnet-feature") + $containerFiles) {
        if (-not (Test-Path -LiteralPath (Join-Path $projectRoot $relative))) {
            throw "C# project is missing: $relative"
        }
    }
}

if ($record.maturity -eq "runnable") {
    foreach ($relative in @(
        "hooks\pre-commit",
        "hooks\pre-push",
        "scripts\install-hooks.ps1",
        "scripts\install-hooks.sh",
        ".github\workflows\security.yml",
        "config\semgrep.yml"
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
