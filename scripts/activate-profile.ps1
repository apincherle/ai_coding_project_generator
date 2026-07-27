param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("java", "python", "csharp", "c", "cpp", "rust", "scala", "typescript-node", "javascript-node", "react-typescript", "nextjs-typescript")]
    [string]$Profile
)

$ErrorActionPreference = "Stop"
$repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$profileRoot = Join-Path $repositoryRoot ".ai\profiles\$Profile"
$activeRoot = Join-Path $repositoryRoot ".ai"
$files = @("project.md", "coding-standards.md", "testing.md", "dependencies.md")

foreach ($file in $files) {
    $source = Join-Path $profileRoot $file
    $target = Join-Path $activeRoot $file
    if (-not (Test-Path -LiteralPath $source)) {
        throw "Profile file not found: $source"
    }
    Copy-Item -LiteralPath $source -Destination $target -Force
}

Write-Output "Activated profile '$Profile'. Review the four changed .ai files before committing."
