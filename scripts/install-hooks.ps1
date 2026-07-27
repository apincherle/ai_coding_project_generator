$ErrorActionPreference = "Stop"
$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
if (-not (Test-Path -LiteralPath (Join-Path $root "hooks\pre-commit"))) {
    throw "Hook files are missing. Generate a runnable profile before installing hooks."
}
$chmod = Get-Command chmod -ErrorAction SilentlyContinue
if ($chmod) {
    & chmod +x -- (Join-Path $root "hooks\pre-commit") (Join-Path $root "hooks\pre-push")
    $installSh = Join-Path $root "scripts\install-hooks.sh"
    if (Test-Path -LiteralPath $installSh) { & chmod +x -- $installSh }
    $mvnw = Join-Path $root "mvnw"
    if (Test-Path -LiteralPath $mvnw) { & chmod +x -- $mvnw }
}
git -C $root config core.hooksPath hooks
Write-Output "Git hooks enabled for this clone. A human remains responsible for Git actions."
