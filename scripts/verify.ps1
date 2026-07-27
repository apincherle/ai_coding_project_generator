$ErrorActionPreference = 'Stop'

$repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$rootPom = Join-Path $repositoryRoot 'pom.xml'
$templatePom = Join-Path $repositoryRoot 'templates\java\pom.xml'

if (Test-Path -LiteralPath $rootPom) {
    $javaRoot = $repositoryRoot
} elseif (Test-Path -LiteralPath $templatePom) {
    $javaRoot = Join-Path $repositoryRoot 'templates\java'
} else {
    throw 'Java verification failed: no root or templates/java pom.xml was found.'
}

Set-Location -LiteralPath $javaRoot
mvn verify
