# Rewrites sample Customer identity in a generated project tree from project-config.

function Get-Utf8NoBomContent {
    param([string]$Path)
    return [System.IO.File]::ReadAllText($Path)
}

function Set-Utf8NoBomContent {
    param([string]$Path, [string]$Content)
    # Keep portable LF endings so Spotless/formatters match Linux CI after Windows generation.
    $normalized = $Content -replace "`r`n", "`n" -replace "`r", "`n"
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($Path, $normalized, $utf8NoBom)
}

function Rename-DirectoryIfExists {
    param([string]$Path, [string]$NewName)
    if (-not (Test-Path -LiteralPath $Path)) { return $null }
    $parent = Split-Path -Parent $Path
    $target = Join-Path $parent $NewName
    if ($Path -eq $target) { return $Path }
    if (Test-Path -LiteralPath $target) {
        throw "Cannot rename '$Path' to existing path '$target'"
    }
    Rename-Item -LiteralPath $Path -NewName $NewName
    return $target
}

function Invoke-TextReplaceInTree {
    param(
        [string]$Root,
        [hashtable]$Replacements,
        [string[]]$ExcludeDirNames = @('.git', 'node_modules', 'target', '.venv', 'bin', 'obj')
    )

    $files = Get-ChildItem -LiteralPath $Root -Recurse -File -Force | Where-Object {
        $relDirs = $_.FullName.Substring($Root.Length).Split([IO.Path]::DirectorySeparatorChar)
        -not ($relDirs | Where-Object { $_ -in $ExcludeDirNames })
    }

    foreach ($file in $files) {
        # Skip obvious binaries
        if ($file.Extension -match '\.(png|jpg|jpeg|gif|pdf|jar|class|dll|exe|zip|lock)$') {
            if ($file.Name -eq 'uv.lock') {
                # uv.lock is text; allow replace of package name
            } else {
                continue
            }
        }
        try {
            $content = Get-Utf8NoBomContent -Path $file.FullName
        } catch {
            continue
        }
        $original = $content
        foreach ($from in $Replacements.Keys) {
            $content = $content.Replace($from, [string]$Replacements[$from])
        }
        if ($content -ne $original) {
            Set-Utf8NoBomContent -Path $file.FullName -Content $content
        }
    }
}

function Invoke-IdentityRewrite {
    param(
        [Parameter(Mandatory = $true)][string]$ProjectRoot,
        [Parameter(Mandatory = $true)]$Config,
        [Parameter(Mandatory = $true)][string]$Profile
    )

    $d = Get-DerivedIdentityNames -Config $Config
    $java = $Config.identity.java
    $py = $Config.identity.python
    $cs = $Config.identity.csharp

    # Ordered replacements as pairs (PowerShell hashtables are case-insensitive).
    $pairs = @(
        @{ From = 'com.example.customer'; To = [string]$java.basePackage },
        @{ From = 'CustomerApiApplication'; To = "$($d.EntityPascal)ApiApplication" },
        @{ From = 'CustomerNotFoundException'; To = "$($d.EntityPascal)NotFoundException" },
        @{ From = 'CreateCustomerRequest'; To = "Create$($d.EntityPascal)Request" },
        @{ From = 'CustomerRequest'; To = "$($d.EntityPascal)Request" },
        @{ From = 'CustomerService'; To = "$($d.EntityPascal)Service" },
        @{ From = 'CustomerRepository'; To = "$($d.EntityPascal)Repository" },
        @{ From = 'JpaCustomerRepository'; To = "Jpa$($d.EntityPascal)Repository" },
        @{ From = 'SpringDataCustomerRepository'; To = "SpringData$($d.EntityPascal)Repository" },
        @{ From = 'CustomerEntity'; To = "$($d.EntityPascal)Entity" },
        @{ From = 'InMemoryCustomerRepository'; To = "InMemory$($d.EntityPascal)Repository" },
        @{ From = 'ICustomerRepository'; To = "I$($d.EntityPascal)Repository" },
        @{ From = 'CustomerApi.Tests'; To = "$($cs.projectName).Tests" },
        @{ From = 'CustomerApi'; To = [string]$cs.projectName },
        @{ From = 'customer_api'; To = [string]$py.packageName },
        @{ From = 'customer-api'; To = [string]$java.artifactId },
        @{ From = 'Customer API'; To = [string]$d.OpenApiTitle },
        @{ From = '/api/v1/customers'; To = "/api/v1/$($d.EntityKebabPlural)" },
        @{ From = 'example.com/problems/customer-not-found'; To = "example.com/problems/$($d.EntityKebab)-not-found" },
        @{ From = 'Customer not found'; To = "$($d.EntityPascal) not found" },
        @{ From = 'create_customers'; To = "create_$($d.EntitySnakePlural)" },
        @{ From = 'V1__create_customers'; To = "V1__create_$($d.EntitySnakePlural)" },
        @{ From = 'CREATE TABLE customers'; To = "CREATE TABLE $($d.DatabaseName)" },
        @{ From = 'TABLE customers'; To = "TABLE $($d.DatabaseName)" },
        @{ From = '@Table(name = "customers")'; To = "@Table(name = `"$($d.DatabaseName)`")" },
        @{ From = 'POSTGRES_DB:-customers'; To = "POSTGRES_DB:-$($d.DatabaseName)" },
        @{ From = '/customers'; To = "/$($d.DatabaseName)" },
        @{ From = 'com.example'; To = [string]$java.groupId },
        @{ From = 'Customers.cs'; To = "$($d.EntityPascalPlural).cs" },
        @{ From = 'Customers'; To = $d.EntityPascalPlural },
        @{ From = 'customers'; To = $d.DatabaseName },
        @{ From = 'Customer'; To = $d.EntityPascal },
        @{ From = 'customer'; To = $d.EntityCamel }
    )

    $files = Get-ChildItem -LiteralPath $ProjectRoot -Recurse -File -Force | Where-Object {
        $p = $_.FullName
        $p -notmatch '\\(\.git|node_modules|target|\.venv|bin|obj)\\' -and
        $p -notmatch '\\.ai\\project-config(\.schema)?\.yml$' -and
        $p -notmatch '\\.ai\\(architecture|api-guidelines|security|governance|business-rules|domain-model|glossary|tooling-policy|version-control-policy|prompts)\.md$'
    }
    foreach ($file in $files) {
        if ($file.Extension -match '\.(png|jpg|jpeg|gif|pdf|jar|class|dll|exe|zip)$') { continue }
        try { $content = Get-Utf8NoBomContent -Path $file.FullName } catch { continue }
        $original = $content
        foreach ($pair in $pairs) {
            $content = $content.Replace($pair.From, [string]$pair.To)
        }
        if ($content -ne $original) {
            Set-Utf8NoBomContent -Path $file.FullName -Content $content
        }
        $newName = $file.Name
        foreach ($pair in $pairs) {
            if ($pair.From.Length -ge 4) {
                $newName = $newName.Replace($pair.From, [string]$pair.To)
            }
        }
        if ($newName -ne $file.Name -and (Test-Path -LiteralPath $file.FullName)) {
            Rename-Item -LiteralPath $file.FullName -NewName $newName
        }
    }

    if ($Profile -eq 'java') {
        $oldPkgPath = Join-Path $ProjectRoot 'src\main\java\com\example\customer'
        $oldTestPath = Join-Path $ProjectRoot 'src\test\java\com\example\customer'
        $pkgParts = ([string]$java.basePackage).Split('.')
        $newMain = Join-Path $ProjectRoot ('src\main\java\' + ($pkgParts -join '\'))
        $newTest = Join-Path $ProjectRoot ('src\test\java\' + ($pkgParts -join '\'))

        if (Test-Path -LiteralPath $oldPkgPath) {
            New-Item -ItemType Directory -Force -Path (Split-Path -Parent $newMain) | Out-Null
            if (-not (Test-Path -LiteralPath $newMain)) {
                Move-Item -LiteralPath $oldPkgPath -Destination $newMain
            }
            # Clean empty com/example leftovers
            $exampleCustomer = Join-Path $ProjectRoot 'src\main\java\com\example'
            if (Test-Path -LiteralPath $exampleCustomer) {
                Get-ChildItem -LiteralPath (Join-Path $ProjectRoot 'src\main\java\com') -Recurse -Directory |
                    Sort-Object FullName -Descending |
                    ForEach-Object {
                        if (@(Get-ChildItem -LiteralPath $_.FullName -Force).Count -eq 0) {
                            Remove-Item -LiteralPath $_.FullName -Force
                        }
                    }
            }
        }
        if (Test-Path -LiteralPath $oldTestPath) {
            New-Item -ItemType Directory -Force -Path (Split-Path -Parent $newTest) | Out-Null
            if (-not (Test-Path -LiteralPath $newTest)) {
                Move-Item -LiteralPath $oldTestPath -Destination $newTest
            }
            Get-ChildItem -LiteralPath (Join-Path $ProjectRoot 'src\test\java\com') -Recurse -Directory -ErrorAction SilentlyContinue |
                Sort-Object FullName -Descending |
                ForEach-Object {
                    if (@(Get-ChildItem -LiteralPath $_.FullName -Force).Count -eq 0) {
                        Remove-Item -LiteralPath $_.FullName -Force -ErrorAction SilentlyContinue
                    }
                }
        }

        # Ensure artifactId in pom matches (text replace should have done customer-api)
        # Fix jar name references if artifact differs from project name patterns already handled
    }

    if ($Profile -eq 'python') {
        $oldPkg = Join-Path $ProjectRoot 'src\customer_api'
        $newPkg = Join-Path $ProjectRoot ("src\" + [string]$py.packageName)
        if ((Test-Path -LiteralPath $oldPkg) -and ($oldPkg -ne $newPkg)) {
            Rename-Item -LiteralPath $oldPkg -NewName ([string]$py.packageName)
        }
        # distribution name: replace in pyproject already via customer-api -> artifactId;
        # also map to python distributionName explicitly
        $pyproject = Join-Path $ProjectRoot 'pyproject.toml'
        if (Test-Path -LiteralPath $pyproject) {
            $c = Get-Utf8NoBomContent -Path $pyproject
            $c = $c.Replace("name = `"$([string]$java.artifactId)`"", "name = `"$([string]$py.distributionName)`"")
            $c = $c.Replace("packages = [`"src/$([string]$py.packageName)`"]", "packages = [`"src/$([string]$py.packageName)`"]")
            Set-Utf8NoBomContent -Path $pyproject -Content $c
        }
    }

    if ($Profile -eq 'csharp') {
        $oldSol = Join-Path $ProjectRoot 'CustomerApi.slnx'
        $newSol = Join-Path $ProjectRoot "$($cs.solutionName).slnx"
        if ((Test-Path -LiteralPath $oldSol) -and ($oldSol -ne $newSol)) {
            Rename-Item -LiteralPath $oldSol -NewName "$($cs.solutionName).slnx"
        }
        # After text replace, folders may still be CustomerApi
        $oldSrc = Join-Path $ProjectRoot 'src\CustomerApi'
        $newSrc = Join-Path $ProjectRoot ("src\" + [string]$cs.projectName)
        if ((Test-Path -LiteralPath $oldSrc) -and ($oldSrc -ne $newSrc)) {
            Rename-Item -LiteralPath $oldSrc -NewName ([string]$cs.projectName)
        }
        $oldTests = Join-Path $ProjectRoot 'tests\CustomerApi.Tests'
        $newTests = Join-Path $ProjectRoot ("tests\" + [string]$cs.projectName + '.Tests')
        if ((Test-Path -LiteralPath $oldTests) -and ($oldTests -ne $newTests)) {
            Rename-Item -LiteralPath $oldTests -NewName ([string]$cs.projectName + '.Tests')
        }
        # Rename csproj files if needed
        Get-ChildItem -LiteralPath $ProjectRoot -Recurse -Filter 'CustomerApi*.csproj' -ErrorAction SilentlyContinue | ForEach-Object {
            $nn = $_.Name.Replace('CustomerApi', [string]$cs.projectName)
            Rename-Item -LiteralPath $_.FullName -NewName $nn
        }
    }
}

function Test-NoSampleIdentityLeft {
    param(
        [Parameter(Mandatory = $true)][string]$ProjectRoot,
        [Parameter(Mandatory = $true)]$Config
    )

    $allowed = @()
    $entity = [string]$Config.entityName
    if ($entity -eq 'Customer') { $allowed += 'Customer', 'customer', 'customers', 'CustomerApi', 'customer_api', 'customer-api' }
    if ([string]$Config.identity.java.groupId -eq 'com.example') { $allowed += 'com.example' }
    if ([string]$Config.identity.java.basePackage -match 'com\.example') { $allowed += 'com.example.customer', 'com.example' }

    $forbidden = @(
        'com.example.customer',
        'CustomerApi',
        'customer_api',
        'customer-api',
        'Customer API',
        'com.example',
        'CustomerService',
        'CustomerRepository'
    )

    $hits = @()
    $files = Get-ChildItem -LiteralPath $ProjectRoot -Recurse -File -Force | Where-Object {
        $_.FullName -notmatch '\\(\.git|node_modules|target|\.venv|bin|obj)\\' -and
        $_.Extension -notmatch '\.(png|jpg|jpeg|gif|pdf|jar|class|dll|exe|zip)$' -and
        $_.Name -ne 'project-config.schema.yml' -and
        $_.FullName -notmatch '\\.ai\\(architecture|api-guidelines|security|governance|business-rules|domain-model|glossary|tooling-policy|version-control-policy|prompts)\.md$' -and
        $_.FullName -notmatch '\\docs\\(generated-project-governance-review|upgrades)\\'
    }
    foreach ($file in $files) {
        # Skip schema docs that mention Customer as example
        if ($file.FullName -match '\\docs\\upgrades\\') { continue }
        try { $content = Get-Utf8NoBomContent -Path $file.FullName } catch { continue }
        foreach ($token in $forbidden) {
            if ($allowed -contains $token) { continue }
            if ($content.Contains($token)) {
                $hits += "$($file.FullName): contains '$token'"
            }
        }
        # Bare Customer word check when entity is not Customer
        if ($entity -ne 'Customer' -and $content -match '\bCustomer\b') {
            $hits += "$($file.FullName): contains word 'Customer'"
        }
    }

    if ($hits.Count -gt 0) {
        $preview = ($hits | Select-Object -First 20) -join "`n"
        throw "Sample identity leftovers detected:`n$preview"
    }
}
