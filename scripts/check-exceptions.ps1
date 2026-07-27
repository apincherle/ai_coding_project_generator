<#
.SYNOPSIS
    Fails when any governance exception record under docs/exceptions has expired.

.DESCRIPTION
    Scans docs/exceptions/*.md (excluding template.md) for an "Expires on (UTC):" field and
    compares it against the current UTC date. Exceptions must not silently outlive their
    approved window and continue weakening a quality or security gate.

.PARAMETER Path
    Directory containing exception record Markdown files. Defaults to ./docs/exceptions
    relative to the current working directory.
#>
[CmdletBinding()]
param(
    [string]$Path = (Join-Path (Get-Location) "docs/exceptions")
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $Path)) {
    Write-Output "No exceptions directory found at $Path; nothing to check."
    exit 0
}

$files = Get-ChildItem -LiteralPath $Path -Filter "*.md" -File |
    Where-Object { $_.Name -ne "template.md" }

if (@($files).Count -eq 0) {
    Write-Output "No exception records found in $Path."
    exit 0
}

$today = [DateTime]::UtcNow.Date
$expired = @()
$invalid = @()

foreach ($file in $files) {
    $content = Get-Content -LiteralPath $file.FullName -Raw
    $match = [regex]::Match($content, '(?im)^-\s*Expires on \(UTC\):\s*(.+)$')
    if (-not $match.Success -or [string]::IsNullOrWhiteSpace($match.Groups[1].Value)) {
        $invalid += $file.Name
        continue
    }

    $rawValue = $match.Groups[1].Value.Trim()
    $parsedDate = [DateTime]::MinValue
    $styles = [System.Globalization.DateTimeStyles]::AssumeUniversal -bor `
        [System.Globalization.DateTimeStyles]::AdjustToUniversal
    $parsed = [DateTime]::TryParse(
        $rawValue,
        [System.Globalization.CultureInfo]::InvariantCulture,
        $styles,
        [ref]$parsedDate)
    if (-not $parsed) {
        $invalid += $file.Name
        continue
    }

    if ($parsedDate.Date -lt $today) {
        $expired += [pscustomobject]@{ File = $file.Name; ExpiresOn = $parsedDate.Date.ToString("yyyy-MM-dd") }
    }
}

if ($invalid.Count -gt 0) {
    Write-Output "Exception record(s) missing or with an unparseable 'Expires on (UTC)' field:"
    foreach ($name in $invalid) { Write-Output "  - $name" }
}

if ($expired.Count -gt 0) {
    Write-Output "Expired exception record(s) (must not continue weakening a gate):"
    foreach ($item in $expired) { Write-Output ("  - {0} expired {1}" -f $item.File, $item.ExpiresOn) }
}

if ($expired.Count -gt 0 -or $invalid.Count -gt 0) {
    throw "check-exceptions failed: $($expired.Count) expired, $($invalid.Count) invalid exception record(s) in $Path."
}

Write-Output "All $(@($files).Count) exception record(s) in $Path are within their approved expiry window."
