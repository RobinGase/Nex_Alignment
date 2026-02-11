$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path

$requiredFiles = @(
    "01_task_header_spoof.md",
    "02_requirements_spoof.md",
    "03_hazard_log_spoof.md",
    "04_runtime_behavioral_contracts_spoof.yaml",
    "05_interaction_contract_spoof.yaml",
    "06_traceability_matrix_spoof.csv",
    "07_design_and_controls_spoof.md",
    "08_telemetry_events_spoof.json",
    "09_residual_risk_spoof.md"
)

$failures = @()

foreach ($f in $requiredFiles) {
    $path = Join-Path $root $f
    if (-not (Test-Path $path)) {
        $failures += "Missing required artifact: $f"
    }
}

$traceCsvPath = Join-Path $root "06_traceability_matrix_spoof.csv"
if (Test-Path $traceCsvPath) {
    $rows = Import-Csv -Path $traceCsvPath
    if ($rows.Count -lt 5) {
        $failures += "Traceability matrix must contain at least 5 rows"
    }

    foreach ($row in $rows) {
        if ($row.requirement_id -notmatch '^REQ-\d+$') { $failures += "Invalid requirement ID: $($row.requirement_id)" }
        if ($row.design_id -notmatch '^DES-\d+$') { $failures += "Invalid design ID: $($row.design_id)" }
        if ($row.code_id -notmatch '^COD-\d+$') { $failures += "Invalid code ID: $($row.code_id)" }
        if ($row.test_id -notmatch '^TST-\d+$') { $failures += "Invalid test ID: $($row.test_id)" }
        if ($row.control_id -notmatch '^CTL-\d+$') { $failures += "Invalid control ID: $($row.control_id)" }
        if ($row.hazard_id -notmatch '^HAZ-\d+$') { $failures += "Invalid hazard ID: $($row.hazard_id)" }
    }
}

$telemetryPath = Join-Path $root "08_telemetry_events_spoof.json"
if (Test-Path $telemetryPath) {
    $events = Get-Content -Path $telemetryPath -Raw | ConvertFrom-Json
    if ($events.Count -lt 3) {
        $failures += "Telemetry must include at least 3 events"
    }

    $requiredEventFields = @("event_id", "timestamp", "schema_version", "source", "context", "event_type", "severity", "description")
    foreach ($event in $events) {
        foreach ($field in $requiredEventFields) {
            if (-not ($event.PSObject.Properties.Name -contains $field)) {
                $failures += "Telemetry event missing field '$field'"
            }
        }
    }
}

$taskHeaderPath = Join-Path $root "01_task_header_spoof.md"
if (Test-Path $taskHeaderPath) {
    $taskHeader = Get-Content -Path $taskHeaderPath -Raw
    if ($taskHeader -notmatch "## Risk Class\s+2") {
        $failures += "Task header must declare Risk Class 2"
    }
    if ($taskHeader -notmatch "## Autonomy Tier\s+A2") {
        $failures += "Task header must declare Autonomy Tier A2"
    }
}

if ($failures.Count -gt 0) {
    Write-Host "Alignment spoof artifact validation FAILED" -ForegroundColor Red
    foreach ($failure in $failures) {
        Write-Host "- $failure" -ForegroundColor Red
    }
    exit 1
}

Write-Host "Alignment spoof artifact validation PASSED" -ForegroundColor Green
Write-Host "Checked artifacts: $($requiredFiles.Count)" -ForegroundColor Green
exit 0
