# Shared project-config load/validate/derive helpers for create-project and validate.

function Get-DerivedIdentityNames {
    param([Parameter(Mandatory = $true)]$Config)

    $entity = [string]$Config.entityName
    if ($entity -notmatch '^[A-Z][A-Za-z0-9]*$') {
        throw "entityName must be PascalCase alphanumeric (e.g. Account). Got: $entity"
    }

    $entityLower = $entity.Substring(0, 1).ToLowerInvariant() + $entity.Substring(1)
    $entityPlural = if ($entity.EndsWith('s')) { $entity + 'es' } else { $entity + 's' }
    $entityLowerPlural = $entityPlural.Substring(0, 1).ToLowerInvariant() + $entityPlural.Substring(1)
    $entitySnake = ($entity -creplace '([a-z0-9])([A-Z])', '$1_$2').ToLowerInvariant()
    $entitySnakePlural = ($entityPlural -creplace '([a-z0-9])([A-Z])', '$1_$2').ToLowerInvariant()
    $entityKebab = $entitySnake.Replace('_', '-')
    $entityKebabPlural = $entitySnakePlural.Replace('_', '-')

    $databaseName = if ($Config.databaseName) { [string]$Config.databaseName } else { $entitySnakePlural }
    $openApiTitle = if ($Config.openApiTitle) { [string]$Config.openApiTitle } else { "$entity API" }

    return [pscustomobject]@{
        EntityPascal       = $entity
        EntityCamel        = $entityLower
        EntityPascalPlural = $entityPlural
        EntityCamelPlural  = $entityLowerPlural
        EntitySnake        = $entitySnake
        EntitySnakePlural  = $entitySnakePlural
        EntityKebab        = $entityKebab
        EntityKebabPlural  = $entityKebabPlural
        DatabaseName       = $databaseName
        OpenApiTitle       = $openApiTitle
    }
}

function Test-ProjectConfigObject {
    param(
        [Parameter(Mandatory = $true)]$Config,
        [Parameter(Mandatory = $true)][string]$ExpectedProjectName
    )

    $requiredTop = @(
        'projectName', 'description', 'entityName', 'owners',
        'riskClassification', 'dataClassification', 'productionCriticality',
        'deploymentTarget', 'identity'
    )
    foreach ($key in $requiredTop) {
        if (-not ($Config.PSObject.Properties.Name -contains $key) -or [string]::IsNullOrWhiteSpace([string]$Config.$key)) {
            if ($key -eq 'owners' -or $key -eq 'identity') {
                if (-not ($Config.PSObject.Properties.Name -contains $key)) {
                    throw "project-config missing required key: $key"
                }
            } else {
                throw "project-config missing or blank required key: $key"
            }
        }
    }

    if ([string]$Config.projectName -ne $ExpectedProjectName) {
        throw "project-config projectName '$($Config.projectName)' must equal ProjectName '$ExpectedProjectName'"
    }

    foreach ($ownerKey in @('technical', 'business')) {
        if (-not ($Config.owners.PSObject.Properties.Name -contains $ownerKey) -or
            [string]::IsNullOrWhiteSpace([string]$Config.owners.$ownerKey)) {
            throw "project-config owners.$ownerKey is required"
        }
    }

    $id = $Config.identity
    foreach ($stack in @('java', 'python', 'csharp')) {
        if (-not ($id.PSObject.Properties.Name -contains $stack)) {
            throw "project-config identity.$stack is required"
        }
    }
    foreach ($k in @('groupId', 'artifactId', 'basePackage')) {
        if ([string]::IsNullOrWhiteSpace([string]$id.java.$k)) { throw "identity.java.$k is required" }
    }
    foreach ($k in @('distributionName', 'packageName')) {
        if ([string]::IsNullOrWhiteSpace([string]$id.python.$k)) { throw "identity.python.$k is required" }
    }
    foreach ($k in @('rootNamespace', 'solutionName', 'projectName')) {
        if ([string]::IsNullOrWhiteSpace([string]$id.csharp.$k)) { throw "identity.csharp.$k is required" }
    }

    $blob = ($Config | ConvertTo-Json -Depth 8)
    foreach ($bad in @('TODO', 'changeme', 'REPLACE_ME', 'example.com')) {
        if ($blob -match [regex]::Escape($bad)) {
            throw "project-config contains forbidden placeholder '$bad'"
        }
    }

    [void](Get-DerivedIdentityNames -Config $Config)
}

function ConvertFrom-SimpleYaml {
    <#
      Minimal YAML subset reader for project-config (mappings + nested mappings + scalars).
      Prefer this over adding a YAML library dependency to catalogue scripts.
    #>
    param([Parameter(Mandatory = $true)][string]$Path)

    $lines = Get-Content -LiteralPath $Path
    $root = [ordered]@{}
    $stack = New-Object System.Collections.ArrayList
    [void]$stack.Add(@{ Indent = -1; Map = $root })

    function Set-MapValue($map, $key, $value) {
        $map[$key] = $value
    }

    foreach ($raw in $lines) {
        if ($raw -match '^\s*#' -or $raw.Trim() -eq '') { continue }
        if ($raw -notmatch '^(?<indent>\s*)(?<key>[A-Za-z0-9_]+):\s*(?<value>.*)$') {
            throw "Unsupported YAML line in ${Path}: $raw"
        }
        $indent = $Matches.indent.Length
        $key = $Matches.key
        $value = $Matches.value.Trim()

        while ($stack.Count -gt 1 -and $indent -le $stack[$stack.Count - 1].Indent) {
            $stack.RemoveAt($stack.Count - 1)
        }
        $current = $stack[$stack.Count - 1].Map

        if ($value -eq '') {
            $child = [ordered]@{}
            Set-MapValue $current $key $child
            [void]$stack.Add(@{ Indent = $indent; Map = $child })
        } else {
            if (($value.StartsWith('"') -and $value.EndsWith('"')) -or ($value.StartsWith("'") -and $value.EndsWith("'"))) {
                $value = $value.Substring(1, $value.Length - 2)
            }
            Set-MapValue $current $key $value
        }
    }

    # Convert ordered hashtables to PSCustomObject recursively
    function Convert-Map($map) {
        $obj = [pscustomobject]@{}
        foreach ($k in $map.Keys) {
            $v = $map[$k]
            if ($v -is [System.Collections.IDictionary]) {
                $obj | Add-Member -NotePropertyName $k -NotePropertyValue (Convert-Map $v)
            } else {
                $obj | Add-Member -NotePropertyName $k -NotePropertyValue $v
            }
        }
        return $obj
    }

    return Convert-Map $root
}

function Write-ProjectConfigYaml {
    param(
        [Parameter(Mandatory = $true)]$Config,
        [Parameter(Mandatory = $true)][string]$Path
    )

    $d = Get-DerivedIdentityNames -Config $Config
    $db = if ($Config.databaseName) { $Config.databaseName } else { $d.DatabaseName }
    $title = if ($Config.openApiTitle) { $Config.openApiTitle } else { $d.OpenApiTitle }

    $yaml = @"
projectName: $($Config.projectName)
description: "$($Config.description -replace '"', '''')"
entityName: $($Config.entityName)
owners:
  technical: "$($Config.owners.technical)"
  business: "$($Config.owners.business)"
riskClassification: $($Config.riskClassification)
dataClassification: $($Config.dataClassification)
productionCriticality: $($Config.productionCriticality)
deploymentTarget: $($Config.deploymentTarget)
identity:
  java:
    groupId: $($Config.identity.java.groupId)
    artifactId: $($Config.identity.java.artifactId)
    basePackage: $($Config.identity.java.basePackage)
  python:
    distributionName: $($Config.identity.python.distributionName)
    packageName: $($Config.identity.python.packageName)
  csharp:
    rootNamespace: $($Config.identity.csharp.rootNamespace)
    solutionName: $($Config.identity.csharp.solutionName)
    projectName: $($Config.identity.csharp.projectName)
databaseName: $db
openApiTitle: "$title"
"@
    $parent = Split-Path -Parent $Path
    New-Item -ItemType Directory -Force -Path $parent | Out-Null
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($Path, $yaml, $utf8NoBom)
}

function New-ProjectConfigFromParameters {
    param(
        [Parameter(Mandatory = $true)][string]$ProjectName,
        [Parameter(Mandatory = $true)][string]$Description,
        [Parameter(Mandatory = $true)][string]$EntityName,
        [Parameter(Mandatory = $true)][string]$TechnicalOwner,
        [Parameter(Mandatory = $true)][string]$BusinessOwner,
        [Parameter(Mandatory = $true)][string]$RiskClassification,
        [Parameter(Mandatory = $true)][string]$DataClassification,
        [Parameter(Mandatory = $true)][string]$ProductionCriticality,
        [Parameter(Mandatory = $true)][string]$DeploymentTarget,
        [string]$JavaGroupId,
        [string]$JavaArtifactId,
        [string]$JavaBasePackage,
        [string]$PythonDistributionName,
        [string]$PythonPackageName,
        [string]$CsharpRootNamespace,
        [string]$CsharpSolutionName,
        [string]$CsharpProjectName,
        [string]$DatabaseName,
        [string]$OpenApiTitle
    )

    foreach ($pair in @(
        @{ Name = 'Description'; Value = $Description },
        @{ Name = 'EntityName'; Value = $EntityName },
        @{ Name = 'TechnicalOwner'; Value = $TechnicalOwner },
        @{ Name = 'BusinessOwner'; Value = $BusinessOwner },
        @{ Name = 'RiskClassification'; Value = $RiskClassification },
        @{ Name = 'DataClassification'; Value = $DataClassification },
        @{ Name = 'ProductionCriticality'; Value = $ProductionCriticality },
        @{ Name = 'DeploymentTarget'; Value = $DeploymentTarget }
    )) {
        if ([string]::IsNullOrWhiteSpace($pair.Value)) {
            throw "Governance field $($pair.Name) is required and must not be blank."
        }
    }

    $artifact = if ($JavaArtifactId) { $JavaArtifactId } else { $ProjectName.ToLowerInvariant() }
    $pyDist = if ($PythonDistributionName) { $PythonDistributionName } else { $artifact }
    $entity = $EntityName
    $snake = ($entity -creplace '([a-z0-9])([A-Z])', '$1_$2').ToLowerInvariant()
    $pyPkg = if ($PythonPackageName) { $PythonPackageName } else { "${snake}_api" }
    $group = if ($JavaGroupId) { $JavaGroupId } else { 'com.acme' }
    $basePkg = if ($JavaBasePackage) { $JavaBasePackage } else { "$group.$snake" }
    $csProj = if ($CsharpProjectName) { $CsharpProjectName } else { "${entity}Api" }
    $csSol = if ($CsharpSolutionName) { $CsharpSolutionName } else { $csProj }
    $csNs = if ($CsharpRootNamespace) { $CsharpRootNamespace } else { "Acme.$csProj" }

    return [pscustomobject]@{
        projectName = $ProjectName
        description = $Description
        entityName = $entity
        owners = [pscustomobject]@{
            technical = $TechnicalOwner
            business = $BusinessOwner
        }
        riskClassification = $RiskClassification
        dataClassification = $DataClassification
        productionCriticality = $ProductionCriticality
        deploymentTarget = $DeploymentTarget
        identity = [pscustomobject]@{
            java = [pscustomobject]@{
                groupId = $group
                artifactId = $artifact
                basePackage = $basePkg
            }
            python = [pscustomobject]@{
                distributionName = $pyDist
                packageName = $pyPkg
            }
            csharp = [pscustomobject]@{
                rootNamespace = $csNs
                solutionName = $csSol
                projectName = $csProj
            }
        }
        databaseName = $DatabaseName
        openApiTitle = $OpenApiTitle
    }
}
