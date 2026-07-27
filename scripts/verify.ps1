$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '..\examples\spring-api')
mvn verify
