param(
    [string]$VersionPath = (Join-Path $PSScriptRoot "..\VERSION.txt"),
    [string]$ProfilesPath = (Join-Path $PSScriptRoot "..\profiles\use_case_profiles.yaml"),
    [string]$BundlesPath = (Join-Path $PSScriptRoot "..\profiles\use_case_bundles.yaml"),
    [string]$RoutesPath = (Join-Path $PSScriptRoot "..\maps\use_case_doc_routes.yaml"),
    [string]$ChangelogPath = (Join-Path $PSScriptRoot "..\CHANGELOG.md")
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-CanonicalVersion {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -Path $Path)) {
        Write-Error "Canonical version file not found at: $Path`nRemediation: Create VERSION.txt at repository root or pass explicit -VersionPath."
        exit 1
    }

    $firstLine = Get-Content -Path $Path | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -First 1
    if ([string]::IsNullOrWhiteSpace($firstLine)) {
        Write-Error "Canonical version file is empty: $Path`nRemediation: Set VERSION.txt to the intended semantic version (for example 1.1.3)."
        exit 1
    }

    return $firstLine.Trim()
}

function Get-YamlVersion {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -Path $Path)) {
        Write-Error "YAML file not found at: $Path`nRemediation: Ensure profile/map catalog file exists or pass explicit path parameter."
        exit 1
    }

    $raw = Get-Content -Path $Path -Raw
    $match = [regex]::Match($raw, '(?m)^version:\s*"?([^"\r\n]+)"?\s*$')
    if (-not $match.Success) {
        Write-Error "Missing or invalid version field in: $Path`nRemediation: Add top-level 'version: \"x.y.z\"' field."
        exit 1
    }

    return $match.Groups[1].Value.Trim()
}

function Get-ChangelogLatestVersion {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -Path $Path)) {
        Write-Error "Changelog not found at: $Path`nRemediation: Ensure CHANGELOG.md exists at repository root or pass explicit -ChangelogPath."
        exit 1
    }

    $raw = Get-Content -Path $Path -Raw
    $match = [regex]::Match($raw, '(?m)^##\s*\[([0-9]+\.[0-9]+\.[0-9]+)\]')
    if (-not $match.Success) {
        Write-Error "Could not locate latest semantic version heading in: $Path`nRemediation: Add heading like '## [1.1.3] - YYYY-MM-DD'."
        exit 1
    }

    return $match.Groups[1].Value.Trim()
}

$canonicalVersion = Get-CanonicalVersion -Path $VersionPath
$checks = @(
    [pscustomobject]@{ label = "profiles/use_case_profiles.yaml"; value = (Get-YamlVersion -Path $ProfilesPath) }
    [pscustomobject]@{ label = "profiles/use_case_bundles.yaml"; value = (Get-YamlVersion -Path $BundlesPath) }
    [pscustomobject]@{ label = "maps/use_case_doc_routes.yaml"; value = (Get-YamlVersion -Path $RoutesPath) }
    [pscustomobject]@{ label = "CHANGELOG.md"; value = (Get-ChangelogLatestVersion -Path $ChangelogPath) }
)

$mismatches = @($checks | Where-Object { $_.value -ne $canonicalVersion })
if ($mismatches.Count -eq 0) {
    Write-Host "OK: All version references aligned to $canonicalVersion"
    exit 0
}

Write-Host "ERROR: Version mismatch found"
Write-Host "  VERSION.txt: $canonicalVersion"
foreach ($entry in $checks) {
    Write-Host "  $($entry.label): $($entry.value)"
}
Write-Host "Remediation: Update mismatched files or run version bump script."
exit 1
