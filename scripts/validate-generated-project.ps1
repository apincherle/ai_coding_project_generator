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
    ".github\pull_request_template.md"
)
foreach ($relative in $required) {
    if (-not (Test-Path -LiteralPath (Join-Path $projectRoot $relative))) {
        throw "Required generated file is missing: $relative"
    }
}

$versionControlPolicy = Get-Content -LiteralPath (Join-Path $projectRoot ".ai\version-control-policy.md") -Raw
if ($versionControlPolicy -notmatch "must never" -or $versionControlPolicy -notmatch "Push or force-push") {
    throw "Human-only version-control policy is incomplete."
}
$agentInstructions = Get-Content -LiteralPath (Join-Path $projectRoot "AGENTS.md") -Raw
if ($agentInstructions -notmatch "Never stage, commit") {
    throw "AGENTS.md does not enforce human-only commit and push."
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

if ($record.profile -eq "python") {
    foreach ($relative in @("pyproject.toml", "src\customer_api\main.py", "tests\test_api.py", "skills\create-python-feature")) {
        if (-not (Test-Path -LiteralPath (Join-Path $projectRoot $relative))) {
            throw "Python project is missing: $relative"
        }
    }
}

if ($record.profile -eq "csharp") {
    foreach ($relative in @("CustomerApi.slnx", "src\CustomerApi\CustomerApi.csproj", "tests\CustomerApi.Tests\CustomerServiceTests.cs", "skills\create-dotnet-feature")) {
        if (-not (Test-Path -LiteralPath (Join-Path $projectRoot $relative))) {
            throw "C# project is missing: $relative"
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
