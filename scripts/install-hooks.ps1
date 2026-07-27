$ErrorActionPreference = "Stop"
$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
if (-not (Test-Path -LiteralPath (Join-Path $root "hooks\pre-commit"))) {
    throw "Hook files are missing. Generate a runnable profile before installing hooks."
}
git -C $root config core.hooksPath hooks
Write-Output "Git hooks enabled for this clone. A human remains responsible for Git actions."
