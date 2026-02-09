param(
    [string]$OutputPath = "NexGentic_Agents_Protocol/audit_outputs/executable_simulation_results.json",
    [string]$ProfilesPath = "NexGentic_Agents_Protocol/profiles/use_case_profiles.yaml",
    [switch]$WriteTelemetrySamples
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptVersion = "2.0.0"
$highAutonomy = @("A2", "A3", "A4")

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

function Get-AutonomyByRank {
    param(
        [Parameter(Mandatory = $true)]
        [int]$Rank
    )

    $map = @{
        0 = "A0"
        1 = "A1"
        2 = "A2"
        3 = "A3"
        4 = "A4"
    }

    if ($map.ContainsKey($Rank)) {
        return $map[$Rank]
    }
    return $null
}

function Get-ProfileCatalog {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path $Path)) {
        throw "Profile catalog not found: $Path"
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

function Resolve-ProfileState {
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$Scenario,
        [Parameter(Mandatory = $true)]
        [hashtable]$ProfileMap
    )

    $reasons = @()
    $hardBlock = $false
    $manualReview = $false
    $incidentArtifactRequired = $false

    $primary = if ($null -ne $Scenario.primary_use_case_profile) { "$($Scenario.primary_use_case_profile)".Trim() } else { "" }
    $secondary = @($Scenario.secondary_use_case_profiles | Where-Object { $null -ne $_ -and "$_".Trim().Length -gt 0 } | ForEach-Object { "$_".Trim() })
    $declared = @()

    if ([string]::IsNullOrWhiteSpace($primary)) {
        $reasons += "missing_primary_profile"
        if ($Scenario.risk_class -ge 2) {
            $hardBlock = $true
        } else {
            $manualReview = $true
        }
    } else {
        $declared += $primary
    }

    if ($secondary.Count -gt 2) {
        $reasons += "secondary_profile_limit_exceeded"
        $hardBlock = $true
        $incidentArtifactRequired = $true
    } else {
        $declared += $secondary
    }

    $dupProfiles = @($declared | Group-Object | Where-Object { $_.Count -gt 1 })
    if ($dupProfiles.Count -gt 0) {
        $reasons += "duplicate_profile_declaration"
        $hardBlock = $true
        $incidentArtifactRequired = $true
    }

    if ($Scenario.composite_profile_conflict) {
        $reasons += "composite_profile_conflict"
        $hardBlock = $true
        $incidentArtifactRequired = $true
    }

    $effectiveProfiles = @()
    $effectiveBundleSet = @{}
    $effectiveTagSet = @{}
    $effectiveMinRisk = 0
    $effectiveCeilingRank = 4

    foreach ($profileId in $declared) {
        if (-not $ProfileMap.ContainsKey($profileId)) {
            $reasons += "unknown_profile_id:$profileId"
            $hardBlock = $true
            continue
        }

        $profile = $ProfileMap[$profileId]
        $effectiveProfiles += $profile.id

        if ($null -ne $profile.min_risk_class -and $profile.min_risk_class -gt $effectiveMinRisk) {
            $effectiveMinRisk = [int]$profile.min_risk_class
        }

        $ceilingRank = Get-AutonomyRank -Tier $profile.autonomy_ceiling
        if (($ceilingRank -ge 0) -and ($ceilingRank -lt $effectiveCeilingRank)) {
            $effectiveCeilingRank = $ceilingRank
        }

        foreach ($bundle in $profile.required_bundles) {
            $effectiveBundleSet[$bundle] = $true
        }
        foreach ($tag in $profile.operation_tags) {
            $effectiveTagSet[$tag] = $true
        }
    }

    $effectiveProfiles = @($effectiveProfiles | Select-Object -Unique)
    $effectiveBundles = @($effectiveBundleSet.Keys | Sort-Object)
    $effectiveCeiling = Get-AutonomyByRank -Rank $effectiveCeilingRank

    $opTags = @($Scenario.operation_tags | Where-Object { $null -ne $_ -and "$_".Trim().Length -gt 0 } | ForEach-Object { "$_".Trim() })
    if ($opTags.Count -gt 0 -and $effectiveTagSet.Count -gt 0) {
        $unknownTags = @()
        foreach ($tag in $opTags) {
            if (-not $effectiveTagSet.ContainsKey($tag)) {
                $unknownTags += $tag
            }
        }

        if ($unknownTags.Count -gt 0) {
            $reasons += "operation_tag_profile_mismatch:" + ($unknownTags -join ",")
            if ($Scenario.risk_class -ge 2) {
                $hardBlock = $true
            } else {
                $manualReview = $true
            }
        }
    }

    if ($effectiveProfiles.Count -gt 0) {
        if ($Scenario.risk_class -lt $effectiveMinRisk) {
            $reasons += "risk_class_below_effective_floor"
            if ($Scenario.risk_class -ge 2) {
                $hardBlock = $true
            } else {
                $manualReview = $true
            }
        }

        $scenarioRank = Get-AutonomyRank -Tier $Scenario.autonomy_tier
        if (($scenarioRank -ge 0) -and ($scenarioRank -gt $effectiveCeilingRank)) {
            $reasons += "autonomy_above_effective_ceiling"
            if ($Scenario.risk_class -ge 2) {
                $hardBlock = $true
            } else {
                $manualReview = $true
            }
        }
    }

    if ($Scenario.override_requested) {
        if ($Scenario.override_missing_expiry -or $Scenario.override_missing_comp_controls) {
            $reasons += "override_missing_required_fields"
            $hardBlock = $true
        }
        if ($Scenario.override_expired) {
            $reasons += "override_expired"
            $hardBlock = $true
        }
        if ($Scenario.override_targets_immutable) {
            $reasons += "override_targets_immutable_control"
            $hardBlock = $true
        }
    }

    $reasons = @($reasons | Select-Object -Unique)
    $profileVerdict = if ($reasons.Count -eq 0) { "match" } else { "mismatch" }

    return [pscustomobject]@{
        profile_verdict = $profileVerdict
        effective_profile_set = @($effectiveProfiles)
        effective_bundle_set = @($effectiveBundles)
        effective_min_risk_class = $effectiveMinRisk
        effective_autonomy_ceiling = $effectiveCeiling
        profile_violation_reasons = @($reasons)
        hard_block = $hardBlock
        manual_review = (-not $hardBlock) -and $manualReview
        incident_artifact_required = $incidentArtifactRequired
    }
}

function Resolve-RuntimeOutcome {
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$Scenario,
        [Parameter(Mandatory = $true)]
        [hashtable]$ProfileMap
    )

    $profileState = Resolve-ProfileState -Scenario $Scenario -ProfileMap $ProfileMap

    if ($profileState.hard_block) {
        return [pscustomobject]@{
            outcome = "block"
            profile_state = $profileState
        }
    }

    if ($profileState.manual_review) {
        return [pscustomobject]@{
            outcome = "manual_review"
            profile_state = $profileState
        }
    }

    if ($Scenario.policy_conflict -or $Scenario.repeated_severe_violation) {
        return [pscustomobject]@{
            outcome = "escalate"
            profile_state = $profileState
        }
    }

    if ($Scenario.fail_closed_condition) {
        return [pscustomobject]@{
            outcome = "block"
            profile_state = $profileState
        }
    }

    $hasEvidenceFailure = $Scenario.missing_artifacts -or $Scenario.invalid_artifacts
    $isHighRiskPath = ($Scenario.risk_class -ge 2) -or ($highAutonomy -contains $Scenario.autonomy_tier)

    if ($hasEvidenceFailure -and $isHighRiskPath) {
        return [pscustomobject]@{
            outcome = "block"
            profile_state = $profileState
        }
    }

    if ($hasEvidenceFailure -and ($Scenario.risk_class -le 1)) {
        return [pscustomobject]@{
            outcome = "warn"
            profile_state = $profileState
        }
    }

    if ($Scenario.residual_risk_unmitigated -or $Scenario.reliability_below_threshold) {
        return [pscustomobject]@{
            outcome = "manual_review"
            profile_state = $profileState
        }
    }

    return [pscustomobject]@{
        outcome = "approve"
        profile_state = $profileState
    }
}

function Get-TelemetryEvents {
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$Scenario,
        [Parameter(Mandatory = $true)]
        [string]$Outcome,
        [Parameter(Mandatory = $true)]
        [pscustomobject]$ProfileState
    )

    $events = @()

    if ($Scenario.missing_artifacts -or $Scenario.invalid_artifacts) {
        $events += "policy_violation"
    }
    if ($Scenario.fail_closed_condition) {
        $events += "security_alert"
    }
    if ($Scenario.reliability_below_threshold) {
        $events += "variance_threshold_exceeded"
    }
    if ($Scenario.residual_risk_unmitigated) {
        $events += "approval_required"
    }
    if ($ProfileState.profile_violation_reasons.Count -gt 0) {
        $events += "profile_violation"
    }
    if ($ProfileState.incident_artifact_required) {
        $events += "incident_artifact_required"
    }

    switch ($Outcome) {
        "approve" { $events += "approval_granted" }
        "manual_review" { $events += "approval_required" }
        "block" { $events += "policy_violation" }
        "escalate" { $events += "risk_acceptance_expiry" }
        "warn" { $events += "telemetry_health" }
    }

    return @($events | Select-Object -Unique)
}

$profiles = Get-ProfileCatalog -Path $ProfilesPath
$profileMap = @{}
foreach ($profile in $profiles) {
    $profileMap[$profile.id] = $profile
}

$scenarios = @(
    [pscustomobject]@{
        id = "SIM-001"
        description = "Class 3 / A2 missing hazard artifacts must block."
        risk_class = 3
        autonomy_tier = "A2"
        primary_use_case_profile = "database_operations"
        secondary_use_case_profiles = @()
        operation_tags = @("database_schema")
        missing_artifacts = $true
        invalid_artifacts = $false
        fail_closed_condition = $false
        residual_risk_unmitigated = $false
        reliability_below_threshold = $false
        policy_conflict = $false
        repeated_severe_violation = $false
        composite_profile_conflict = $false
        override_requested = $false
        override_missing_expiry = $false
        override_missing_comp_controls = $false
        override_expired = $false
        override_targets_immutable = $false
        expected_outcome = "block"
    }
    [pscustomobject]@{
        id = "SIM-002"
        description = "Class 1 / A1 minor optional issue should warn."
        risk_class = 1
        autonomy_tier = "A1"
        primary_use_case_profile = "website_frontend"
        secondary_use_case_profiles = @()
        operation_tags = @("frontend")
        missing_artifacts = $true
        invalid_artifacts = $false
        fail_closed_condition = $false
        residual_risk_unmitigated = $false
        reliability_below_threshold = $false
        policy_conflict = $false
        repeated_severe_violation = $false
        composite_profile_conflict = $false
        override_requested = $false
        override_missing_expiry = $false
        override_missing_comp_controls = $false
        override_expired = $false
        override_targets_immutable = $false
        expected_outcome = "warn"
    }
    [pscustomobject]@{
        id = "SIM-003"
        description = "Residual risk unresolved should require manual review."
        risk_class = 2
        autonomy_tier = "A2"
        primary_use_case_profile = "api_backend_services"
        secondary_use_case_profiles = @()
        operation_tags = @("api_change")
        missing_artifacts = $false
        invalid_artifacts = $false
        fail_closed_condition = $false
        residual_risk_unmitigated = $true
        reliability_below_threshold = $false
        policy_conflict = $false
        repeated_severe_violation = $false
        composite_profile_conflict = $false
        override_requested = $false
        override_missing_expiry = $false
        override_missing_comp_controls = $false
        override_expired = $false
        override_targets_immutable = $false
        expected_outcome = "manual_review"
    }
    [pscustomobject]@{
        id = "SIM-004"
        description = "Repeated severe governance violations escalate."
        risk_class = 4
        autonomy_tier = "A3"
        primary_use_case_profile = "security_incident_response"
        secondary_use_case_profiles = @()
        operation_tags = @("incident_triage")
        missing_artifacts = $false
        invalid_artifacts = $false
        fail_closed_condition = $false
        residual_risk_unmitigated = $false
        reliability_below_threshold = $true
        policy_conflict = $false
        repeated_severe_violation = $true
        composite_profile_conflict = $false
        override_requested = $false
        override_missing_expiry = $false
        override_missing_comp_controls = $false
        override_expired = $false
        override_targets_immutable = $false
        expected_outcome = "escalate"
    }
    [pscustomobject]@{
        id = "SIM-005"
        description = "Clean Class 2 / A1 path should approve."
        risk_class = 2
        autonomy_tier = "A1"
        primary_use_case_profile = "api_backend_services"
        secondary_use_case_profiles = @()
        operation_tags = @("backend_logic")
        missing_artifacts = $false
        invalid_artifacts = $false
        fail_closed_condition = $false
        residual_risk_unmitigated = $false
        reliability_below_threshold = $false
        policy_conflict = $false
        repeated_severe_violation = $false
        composite_profile_conflict = $false
        override_requested = $false
        override_missing_expiry = $false
        override_missing_comp_controls = $false
        override_expired = $false
        override_targets_immutable = $false
        expected_outcome = "approve"
    }
    [pscustomobject]@{
        id = "SIM-006"
        description = "Fail-closed integrity mismatch forces block."
        risk_class = 2
        autonomy_tier = "A2"
        primary_use_case_profile = "infrastructure_devops"
        secondary_use_case_profiles = @()
        operation_tags = @("deployment")
        missing_artifacts = $false
        invalid_artifacts = $true
        fail_closed_condition = $true
        residual_risk_unmitigated = $false
        reliability_below_threshold = $false
        policy_conflict = $false
        repeated_severe_violation = $false
        composite_profile_conflict = $false
        override_requested = $false
        override_missing_expiry = $false
        override_missing_comp_controls = $false
        override_expired = $false
        override_targets_immutable = $false
        expected_outcome = "block"
    }
    [pscustomobject]@{
        id = "SIM-007"
        description = "Risk floor violation for payments profile must block."
        risk_class = 2
        autonomy_tier = "A2"
        primary_use_case_profile = "payments_transfers"
        secondary_use_case_profiles = @()
        operation_tags = @("currency_transfer")
        missing_artifacts = $false
        invalid_artifacts = $false
        fail_closed_condition = $false
        residual_risk_unmitigated = $false
        reliability_below_threshold = $false
        policy_conflict = $false
        repeated_severe_violation = $false
        composite_profile_conflict = $false
        override_requested = $false
        override_missing_expiry = $false
        override_missing_comp_controls = $false
        override_expired = $false
        override_targets_immutable = $false
        expected_outcome = "block"
    }
    [pscustomobject]@{
        id = "SIM-008"
        description = "Unknown profile ID must block."
        risk_class = 3
        autonomy_tier = "A2"
        primary_use_case_profile = "quantum_retail_web"
        secondary_use_case_profiles = @()
        operation_tags = @("frontend")
        missing_artifacts = $false
        invalid_artifacts = $false
        fail_closed_condition = $false
        residual_risk_unmitigated = $false
        reliability_below_threshold = $false
        policy_conflict = $false
        repeated_severe_violation = $false
        composite_profile_conflict = $false
        override_requested = $false
        override_missing_expiry = $false
        override_missing_comp_controls = $false
        override_expired = $false
        override_targets_immutable = $false
        expected_outcome = "block"
    }
    [pscustomobject]@{
        id = "SIM-009"
        description = "Composite profile conflict must block and require incident artifact."
        risk_class = 3
        autonomy_tier = "A2"
        primary_use_case_profile = "third_party_integration"
        secondary_use_case_profiles = @("identity_kyc_auth")
        operation_tags = @("third_party_api", "identity_verification")
        missing_artifacts = $false
        invalid_artifacts = $false
        fail_closed_condition = $false
        residual_risk_unmitigated = $false
        reliability_below_threshold = $false
        policy_conflict = $false
        repeated_severe_violation = $false
        composite_profile_conflict = $true
        override_requested = $false
        override_missing_expiry = $false
        override_missing_comp_controls = $false
        override_expired = $false
        override_targets_immutable = $false
        expected_outcome = "block"
    }
    [pscustomobject]@{
        id = "SIM-010"
        description = "Expired override must block."
        risk_class = 3
        autonomy_tier = "A2"
        primary_use_case_profile = "payments_transfers"
        secondary_use_case_profiles = @()
        operation_tags = @("currency_transfer")
        missing_artifacts = $false
        invalid_artifacts = $false
        fail_closed_condition = $false
        residual_risk_unmitigated = $false
        reliability_below_threshold = $false
        policy_conflict = $false
        repeated_severe_violation = $false
        composite_profile_conflict = $false
        override_requested = $true
        override_missing_expiry = $false
        override_missing_comp_controls = $false
        override_expired = $true
        override_targets_immutable = $false
        expected_outcome = "block"
    }
    [pscustomobject]@{
        id = "SIM-011"
        description = "Low-risk profile mismatch should trigger manual review."
        risk_class = 1
        autonomy_tier = "A1"
        primary_use_case_profile = "website_frontend"
        secondary_use_case_profiles = @()
        operation_tags = @("currency_transfer")
        missing_artifacts = $false
        invalid_artifacts = $false
        fail_closed_condition = $false
        residual_risk_unmitigated = $false
        reliability_below_threshold = $false
        policy_conflict = $false
        repeated_severe_violation = $false
        composite_profile_conflict = $false
        override_requested = $false
        override_missing_expiry = $false
        override_missing_comp_controls = $false
        override_expired = $false
        override_targets_immutable = $false
        expected_outcome = "manual_review"
    }
    [pscustomobject]@{
        id = "SIM-012"
        description = "Autonomy ceiling violation for database profile must block."
        risk_class = 2
        autonomy_tier = "A3"
        primary_use_case_profile = "database_operations"
        secondary_use_case_profiles = @()
        operation_tags = @("database_schema")
        missing_artifacts = $false
        invalid_artifacts = $false
        fail_closed_condition = $false
        residual_risk_unmitigated = $false
        reliability_below_threshold = $false
        policy_conflict = $false
        repeated_severe_violation = $false
        composite_profile_conflict = $false
        override_requested = $false
        override_missing_expiry = $false
        override_missing_comp_controls = $false
        override_expired = $false
        override_targets_immutable = $false
        expected_outcome = "block"
    }
)

$scenarioResults = @()
foreach ($scenario in $scenarios) {
    $resolved = Resolve-RuntimeOutcome -Scenario $scenario -ProfileMap $profileMap
    $actual = $resolved.outcome
    $profileState = $resolved.profile_state
    $pass = ($actual -eq $scenario.expected_outcome)

    $result = [ordered]@{
        id = $scenario.id
        description = $scenario.description
        risk_class = $scenario.risk_class
        autonomy_tier = $scenario.autonomy_tier
        primary_use_case_profile = $scenario.primary_use_case_profile
        secondary_use_case_profiles = @($scenario.secondary_use_case_profiles)
        operation_tags = @($scenario.operation_tags)
        profile_verdict = $profileState.profile_verdict
        effective_profile_set = @($profileState.effective_profile_set)
        effective_bundle_set = @($profileState.effective_bundle_set)
        profile_violation_reasons = @($profileState.profile_violation_reasons)
        incident_artifact_required = $profileState.incident_artifact_required
        expected_outcome = $scenario.expected_outcome
        actual_outcome = $actual
        pass = $pass
        telemetry_event_types = Get-TelemetryEvents -Scenario $scenario -Outcome $actual -ProfileState $profileState
    }

    if ($WriteTelemetrySamples) {
        $result["telemetry_sample"] = [ordered]@{
            event_id = "EVT-$($scenario.id)"
            source = "simulation_runner"
            event_type = ($result.telemetry_event_types | Select-Object -First 1)
            task_id = $scenario.id
            risk_class = $scenario.risk_class
            autonomy_tier = $scenario.autonomy_tier
            outcome = $actual
            profile_verdict = $profileState.profile_verdict
        }
    }

    $scenarioResults += [pscustomobject]$result
}

$total = $scenarioResults.Count
$passed = ($scenarioResults | Where-Object { $_.pass }).Count
$failed = $total - $passed

$report = [ordered]@{
    metadata = [ordered]@{
        generated_at_utc = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        script_version = $scriptVersion
        profiles_path = $ProfilesPath
        decision_authority_docs = @(
            "runtime/compliance_runtime_spec.md",
            "runtime/unified_governance_decision_model.md"
        )
        advisory_docs = @(
            "evaluation/nap_evaluation_harness.md",
            "evaluation/multi_lens_evaluation_harness.md"
        )
    }
    summary = [ordered]@{
        total_scenarios = $total
        passed = $passed
        failed = $failed
        status = if ($failed -eq 0) { "pass" } else { "fail" }
    }
    scenarios = $scenarioResults
}

$outputDir = Split-Path -Path $OutputPath -Parent
if ($outputDir -and -not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

$report | ConvertTo-Json -Depth 12 | Set-Content -Path $OutputPath -Encoding UTF8

Write-Host "Simulation report written to $OutputPath"
Write-Host "Scenarios: $total, Passed: $passed, Failed: $failed"

if ($failed -gt 0) {
    exit 2
}

exit 0

