param(
    [string]$ProfilesPath = (Join-Path $PSScriptRoot "..\profiles\use_case_profiles.yaml"),
    [string]$BundlesPath = (Join-Path $PSScriptRoot "..\profiles\use_case_bundles.yaml"),
    [string]$OutputPath = (Join-Path $PSScriptRoot "..\audit_outputs\use_case_profile_validation_report.json")
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-ListFromBlock {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Block,
        [Parameter(Mandatory = $true)]
        [string]$Key
    )

    $items = @()
    $lines = $Block -split "`r?`n"
    $collect = $false
    $escapedKey = [regex]::Escape($Key)

    foreach ($line in $lines) {
        if (-not $collect) {
            if ($line -match "^\s*$escapedKey\s*:\s*$") {
                $collect = $true
            }
            continue
        }

        if ($line -match "^\s*-\s*(.+?)\s*$") {
            $items += $matches[1].Trim()
            continue
        }

        if ($line -match "^\s*[A-Za-z0-9_]+\s*:\s*") {
            break
        }
    }

    return @($items)
}

function Get-AutonomyRank {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Tier
    )

    $map = @{
        "A0" = 0
        "A1" = 1
        "A2" = 2
        "A3" = 3
        "A4" = 4
    }

    if ($map.ContainsKey($Tier)) {
        return [int]$map[$Tier]
    }
    return -1
}

function Get-BundleCatalog {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -Path $Path)) {
        Write-Error "Bundle catalog not found at: $Path`nRemediation: Run from repository root or provide explicit -BundlesPath parameter."
        exit 1
    }

    $raw = Get-Content -Path $Path -Raw
    $versionMatch = [regex]::Match($raw, "(?m)^version:\s*""?([^""\r\n]+)""?\s*$")
    $version = if ($versionMatch.Success) { $versionMatch.Groups[1].Value.Trim() } else { $null }

    $blocks = [regex]::Split($raw, "(?m)^  - id:\s*")
    $bundles = @()

    for ($i = 1; $i -lt $blocks.Count; $i++) {
        $block = $blocks[$i]
        $id = (($block -split "`r?`n")[0]).Trim()
        $purposeMatch = [regex]::Match($block, "(?m)^\s*purpose:\s*(.+?)\s*$")
        $anchors = Get-ListFromBlock -Block $block -Key "primary_nap_anchors"

        $bundles += [pscustomobject]@{
            id = $id
            purpose = if ($purposeMatch.Success) { $purposeMatch.Groups[1].Value.Trim() } else { $null }
            primary_nap_anchors = @($anchors)
        }
    }

    return [pscustomobject]@{
        version = $version
        bundles = @($bundles)
    }
}

function Get-ProfileCatalog {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -Path $Path)) {
        Write-Error "Profile catalog not found at: $Path`nRemediation: Run from repository root or provide explicit -ProfilesPath parameter."
        exit 1
    }

    $raw = Get-Content -Path $Path -Raw
    $versionMatch = [regex]::Match($raw, "(?m)^version:\s*""?([^""\r\n]+)""?\s*$")
    $version = if ($versionMatch.Success) { $versionMatch.Groups[1].Value.Trim() } else { $null }

    $blocks = [regex]::Split($raw, "(?m)^  - id:\s*")
    $profiles = @()

    for ($i = 1; $i -lt $blocks.Count; $i++) {
        $block = $blocks[$i]
        $id = (($block -split "`r?`n")[0]).Trim()
        $workMatch = [regex]::Match($block, "(?m)^\s*typical_work:\s*(.+?)\s*$")
        $minRiskMatch = [regex]::Match($block, "(?m)^\s*min_risk_class:\s*([0-9]+)\s*$")
        $ceilingMatch = [regex]::Match($block, "(?m)^\s*autonomy_ceiling:\s*([A-Za-z0-9_]+)\s*$")
        $requiredBundles = Get-ListFromBlock -Block $block -Key "required_bundles"
        $operationTags = Get-ListFromBlock -Block $block -Key "operation_tags"

        $profiles += [pscustomobject]@{
            id = $id
            typical_work = if ($workMatch.Success) { $workMatch.Groups[1].Value.Trim() } else { $null }
            min_risk_class = if ($minRiskMatch.Success) { [int]$minRiskMatch.Groups[1].Value } else { $null }
            autonomy_ceiling = if ($ceilingMatch.Success) { $ceilingMatch.Groups[1].Value.Trim() } else { $null }
            required_bundles = @($requiredBundles)
            operation_tags = @($operationTags)
        }
    }

    return [pscustomobject]@{
        version = $version
        profiles = @($profiles)
    }
}

$bundleCatalog = Get-BundleCatalog -Path $BundlesPath
$profileCatalog = Get-ProfileCatalog -Path $ProfilesPath

$violations = @()
$warnings = @()

$bundleIds = @($bundleCatalog.bundles | ForEach-Object { $_.id })
$profileIds = @($profileCatalog.profiles | ForEach-Object { $_.id })

$dupBundles = $bundleIds | Group-Object | Where-Object { $_.Count -gt 1 }
foreach ($dup in $dupBundles) {
    $violations += "Duplicate bundle ID: $($dup.Name)"
}

$dupProfiles = $profileIds | Group-Object | Where-Object { $_.Count -gt 1 }
foreach ($dup in $dupProfiles) {
    $violations += "Duplicate profile ID: $($dup.Name)"
}

if ($bundleCatalog.bundles.Count -eq 0) {
    $violations += "No bundles were parsed from $BundlesPath."
}

if ($profileCatalog.profiles.Count -eq 0) {
    $violations += "No profiles were parsed from $ProfilesPath."
}

if ($profileCatalog.profiles.Count -ne 12) {
    $warnings += "Profile count is $($profileCatalog.profiles.Count); expected 12 for Profile Pack v1."
}

$referencedBundles = @{}
foreach ($profile in $profileCatalog.profiles) {
    if ($null -eq $profile.min_risk_class -or $profile.min_risk_class -lt 0 -or $profile.min_risk_class -gt 4) {
        $violations += "Profile '$($profile.id)' has invalid min_risk_class '$($profile.min_risk_class)'."
    }

    if ((Get-AutonomyRank -Tier $profile.autonomy_ceiling) -lt 0) {
        $violations += "Profile '$($profile.id)' has invalid autonomy_ceiling '$($profile.autonomy_ceiling)'."
    }

    if ($profile.required_bundles.Count -eq 0) {
        $violations += "Profile '$($profile.id)' has no required_bundles."
    }

    foreach ($bundleId in $profile.required_bundles) {
        if ($bundleId -notin $bundleIds) {
            $violations += "Profile '$($profile.id)' references unknown bundle '$bundleId'."
        } else {
            $referencedBundles[$bundleId] = $true
        }
    }

    if ($profile.operation_tags.Count -eq 0) {
        $warnings += "Profile '$($profile.id)' has no operation_tags."
    }
}

foreach ($bundle in $bundleCatalog.bundles) {
    if ($bundle.primary_nap_anchors.Count -eq 0) {
        $warnings += "Bundle '$($bundle.id)' has no primary_nap_anchors."
    }
    if (-not $referencedBundles.ContainsKey($bundle.id)) {
        $warnings += "Bundle '$($bundle.id)' is not referenced by any profile."
    }
}

$status = if ($violations.Count -eq 0) { "pass" } else { "fail" }

$report = [ordered]@{
    metadata = [ordered]@{
        generated_at_utc = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        profiles_path = $ProfilesPath
        bundles_path = $BundlesPath
        profile_catalog_version = $profileCatalog.version
        bundle_catalog_version = $bundleCatalog.version
    }
    summary = [ordered]@{
        status = $status
        bundle_count = $bundleCatalog.bundles.Count
        profile_count = $profileCatalog.profiles.Count
        violation_count = $violations.Count
        warning_count = $warnings.Count
    }
    bundles = $bundleCatalog.bundles
    profiles = $profileCatalog.profiles
    violations = $violations
    warnings = $warnings
}

$outputDir = Split-Path -Path $OutputPath -Parent
if ($outputDir -and -not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

$report | ConvertTo-Json -Depth 12 | Set-Content -Path $OutputPath -Encoding UTF8

Write-Host "Use-case profile validation report written to $OutputPath"
Write-Host "Bundles: $($bundleCatalog.bundles.Count), Profiles: $($profileCatalog.profiles.Count), Violations: $($violations.Count), Warnings: $($warnings.Count)"

if ($violations.Count -gt 0) {
    exit 2
}

exit 0
