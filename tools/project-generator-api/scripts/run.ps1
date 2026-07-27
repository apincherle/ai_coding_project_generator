param(
    [string]$HostAddress = "127.0.0.1",
    [int]$Port = 8090
)

$ErrorActionPreference = "Stop"
$apiRoot = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path -LiteralPath (Join-Path $apiRoot "pyproject.toml"))) {
    $apiRoot = $PSScriptRoot
}

Set-Location -LiteralPath $apiRoot
if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    throw "uv is required. Install from https://docs.astral.sh/uv/ and retry."
}

uv sync
Write-Output "Swagger UI: http://${HostAddress}:${Port}/docs"
uv run uvicorn generator_api.main:app --app-dir src --host $HostAddress --port $Port
