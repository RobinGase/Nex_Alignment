param(
    [string]$RulesPath = (Join-Path $PSScriptRoot "..\templates\policy_engine_rules.yaml"),
    [string]$ProfilesPath = (Join-Path $PSScriptRoot "..\profiles\use_case_profiles.yaml"),
    [string]$BundlesPath = (Join-Path $PSScriptRoot "..\profiles\use_case_bundles.yaml"),
    [string]$OutputPath = (Join-Path $PSScriptRoot "..\audit_outputs\policy_runtime_parity_report.json")
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
    $blocks = [regex]::Split($raw, "(?m)^  - id:\s*")
    $bundleIds = @()

    for ($i = 1; $i -lt $blocks.Count; $i++) {
        $block = $blocks[$i]
        $id = (($block -split "`r?`n")[0]).Trim()
        if ($id) {
            $bundleIds += $id
        }
    }

    return @($bundleIds)
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
    $blocks = [regex]::Split($raw, "(?m)^  - id:\s*")
    $profiles = @()

    for ($i = 1; $i -lt $blocks.Count; $i++) {
        $block = $blocks[$i]
        $id = (($block -split "`r?`n")[0]).Trim()

        $minRiskMatch = [regex]::Match($block, "(?m)^\s*min_risk_class:\s*([0-9]+)\s*$")
        $ceilingMatch = [regex]::Match($block, "(?m)^\s*autonomy_ceiling:\s*([A-Za-z0-9_]+)\s*$")

        $requiredBundles = Get-ListFromBlock -Block $block -Key "required_bundles"
        $operationTags = Get-ListFromBlock -Block $block -Key "operation_tags"

        $profiles += [pscustomobject]@{
            id = $id
            min_risk_class = if ($minRiskMatch.Success) { [int]$minRiskMatch.Groups[1].Value } else { $null }
            autonomy_ceiling = if ($ceilingMatch.Success) { $ceilingMatch.Groups[1].Value } else { $null }
            required_bundles = @($requiredBundles)
            operation_tags = @($operationTags)
        }
    }

    return @($profiles)
}

if (-not (Test-Path -Path $RulesPath)) {
    Write-Error "Rules file not found at: $RulesPath`nRemediation: Run from repository root or provide explicit -RulesPath parameter."
    exit 1
}

$bundleIds = Get-BundleCatalog -Path $BundlesPath
$profiles = Get-ProfileCatalog -Path $ProfilesPath
$profileMap = @{}
foreach ($profile in $profiles) {
    $profileMap[$profile.id] = $profile
}

$rawRules = Get-Content -Path $RulesPath -Raw
$ruleBlocks = [regex]::Split($rawRules, "(?m)^  - name:\s*")

$rules = @()
for ($i = 1; $i -lt $ruleBlocks.Count; $i++) {
    $block = $ruleBlocks[$i]
    $name = (($block -split "`r?`n")[0]).Trim()

    $riskMatch = [regex]::Match($block, "(?m)^\s*risk_class:\s*([0-9]+)\s*$")
    $autonomyMatch = [regex]::Match($block, "(?m)^\s*autonomy_tier:\s*([A-Za-z0-9_]+)\s*$")

    $approvals = Get-ListFromBlock -Block $block -Key "approvals"
    $useCaseProfiles = Get-ListFromBlock -Block $block -Key "use_case_profiles"
    $requiredProfileBundles = Get-ListFromBlock -Block $block -Key "required_profile_bundles"

    $hasRequiredArtifacts = [regex]::IsMatch($block, "(?m)^\s*required_artifacts:\s*$")
    $hasGates = [regex]::IsMatch($block, "(?m)^\s*gates:\s*$")

    $rules += [pscustomobject]@{
        name = $name
        risk_class = if ($riskMatch.Success) { [int]$riskMatch.Groups[1].Value } else { $null }
        autonomy_tier = if ($autonomyMatch.Success) { $autonomyMatch.Groups[1].Value } else { $null }
        approvals = @($approvals)
        use_case_profiles = @($useCaseProfiles)
        required_profile_bundles = @($requiredProfileBundles)
        has_required_artifacts = $hasRequiredArtifacts
        has_gates = $hasGates
    }
}

$violations = @()
$warnings = @()

# Duplicate rule names
$dups = $rules | Group-Object name | Where-Object { $_.Count -gt 1 }
foreach ($dup in $dups) {
    $violations += "Duplicate rule name: $($dup.Name)"
}

foreach ($rule in $rules) {
    if ($null -eq $rule.risk_class) {
        $violations += "Rule '$($rule.name)' is missing risk_class."
    }
    if ($null -eq $rule.autonomy_tier) {
        $violations += "Rule '$($rule.name)' is missing autonomy_tier."
    }

    if ($rule.autonomy_tier -and (Get-AutonomyRank -Tier $rule.autonomy_tier) -lt 0) {
        $violations += "Rule '$($rule.name)' uses unknown autonomy tier '$($rule.autonomy_tier)'."
    }

    # Normative parity: A4 prohibited for Class 0-2
    if (($rule.autonomy_tier -eq "A4") -and ($rule.risk_class -ge 0) -and ($rule.risk_class -le 2)) {
        $violations += "Rule '$($rule.name)' violates runtime policy: A4 is prohibited for Class 0-2."
    }

    # Runtime expectation: A2-A4 require approvals
    if (($rule.autonomy_tier -in @("A2", "A3", "A4")) -and ($rule.approvals.Count -eq 0)) {
        $violations += "Rule '$($rule.name)' has autonomy $($rule.autonomy_tier) but no approvals configured."
    }

    if (-not $rule.has_required_artifacts) {
        $warnings += "Rule '$($rule.name)' is missing required_artifacts section."
    }
    if (-not $rule.has_gates) {
        $warnings += "Rule '$($rule.name)' is missing gates section."
    }

    # Validate declared profile IDs.
    $expectedBundles = @{}
    foreach ($profileId in $rule.use_case_profiles) {
        if (-not $profileMap.ContainsKey($profileId)) {
            $violations += "Rule '$($rule.name)' references unknown profile '$profileId'."
            continue
        }

        $profile = $profileMap[$profileId]
        foreach ($bundleId in $profile.required_bundles) {
            $expectedBundles[$bundleId] = $true
        }

        if ($null -ne $rule.risk_class -and $rule.risk_class -lt $profile.min_risk_class) {
            $violations += "Rule '$($rule.name)' risk_class $($rule.risk_class) is below profile floor $($profile.min_risk_class) for '$profileId'."
        }

        if ($rule.autonomy_tier) {
            $ruleRank = Get-AutonomyRank -Tier $rule.autonomy_tier
            $ceilingRank = Get-AutonomyRank -Tier $profile.autonomy_ceiling
            if (($ruleRank -ge 0) -and ($ceilingRank -ge 0) -and ($ruleRank -gt $ceilingRank)) {
                $violations += "Rule '$($rule.name)' autonomy_tier $($rule.autonomy_tier) exceeds profile ceiling $($profile.autonomy_ceiling) for '$profileId'."
            }
        }
    }

    # Validate profile bundles declared by the rule.
    foreach ($bundleId in $rule.required_profile_bundles) {
        if ($bundleId -notin $bundleIds) {
            $violations += "Rule '$($rule.name)' references unknown profile bundle '$bundleId'."
        }
    }

    if ($rule.use_case_profiles.Count -gt 0) {
        if ($rule.required_profile_bundles.Count -eq 0) {
            $warnings += "Rule '$($rule.name)' declares use_case_profiles but no required_profile_bundles."
        } else {
            foreach ($expectedBundle in $expectedBundles.Keys) {
                if ($expectedBundle -notin $rule.required_profile_bundles) {
                    $violations += "Rule '$($rule.name)' is missing expected profile bundle '$expectedBundle'."
                }
            }

            foreach ($declaredBundle in $rule.required_profile_bundles) {
                if (-not $expectedBundles.ContainsKey($declaredBundle)) {
                    $warnings += "Rule '$($rule.name)' declares extra profile bundle '$declaredBundle' not required by selected profiles."
                }
            }
        }
    }
}

$status = if ($violations.Count -eq 0) { "pass" } else { "fail" }
$report = [ordered]@{
    metadata = [ordered]@{
        generated_at_utc = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        rules_path = $RulesPath
        profiles_path = $ProfilesPath
        bundles_path = $BundlesPath
        parity_contract = @(
            "runtime/compliance_runtime_spec.md",
            "runtime/unified_governance_decision_model.md"
        )
    }
    summary = [ordered]@{
        total_rules = $rules.Count
        total_profiles = $profiles.Count
        total_bundles = $bundleIds.Count
        status = $status
        violation_count = $violations.Count
        warning_count = $warnings.Count
    }
    rules = $rules
    violations = $violations
    warnings = $warnings
}

$outputDir = Split-Path -Path $OutputPath -Parent
if ($outputDir -and -not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

$report | ConvertTo-Json -Depth 10 | Set-Content -Path $OutputPath -Encoding UTF8
Write-Host "Parity report written to $OutputPath"
Write-Host "Rules: $($rules.Count), Violations: $($violations.Count), Warnings: $($warnings.Count)"

if ($violations.Count -gt 0) {
    exit 2
}

exit 0

