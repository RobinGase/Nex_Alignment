param(
    [string]$EnvPath = (Join-Path $PSScriptRoot "..\.env"),
    [string]$OutputPath = (Join-Path $PSScriptRoot "..\audit_outputs\optional_workflow_results.json"),
    [switch]$Strict
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptVersion = "1.0.0"
$notionVersion = "2022-06-28"

function ConvertTo-Bool {
    param(
        [AllowNull()]
        [string]$Value,
        [bool]$Default = $false
    )

    if ($null -eq $Value) {
        return $Default
    }

    $normalized = $Value.Trim().ToLowerInvariant()
    if ($normalized -in @("1", "true", "yes", "on")) {
        return $true
    }
    if ($normalized -in @("0", "false", "no", "off")) {
        return $false
    }

    return $Default
}

function Get-EffectiveEnvValue {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$DotEnv,
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    $processValue = [Environment]::GetEnvironmentVariable($Name, "Process")
    if (-not [string]::IsNullOrWhiteSpace($processValue)) {
        return $processValue
    }

    if ($DotEnv.ContainsKey($Name) -and -not [string]::IsNullOrWhiteSpace([string]$DotEnv[$Name])) {
        return [string]$DotEnv[$Name]
    }

    return $null
}

function Read-DotEnv {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $values = @{}

    if (-not (Test-Path -Path $Path)) {
        Write-Warning "Environment file not found at: $Path`nRemediation: Create .env from .env.example or provide explicit -EnvPath parameter."
        return $values
    }

    $lines = Get-Content -Path $Path
    foreach ($rawLine in $lines) {
        $line = $rawLine.Trim()
        if ([string]::IsNullOrWhiteSpace($line) -or $line.StartsWith("#")) {
            continue
        }

        $idx = $line.IndexOf("=")
        if ($idx -lt 1) {
            continue
        }

        $key = $line.Substring(0, $idx).Trim()
        $value = $line.Substring($idx + 1).Trim()

        if (
            ($value.StartsWith('"') -and $value.EndsWith('"') -and $value.Length -ge 2) -or
            ($value.StartsWith("'") -and $value.EndsWith("'") -and $value.Length -ge 2)
        ) {
            $value = $value.Substring(1, $value.Length - 2)
        }

        $values[$key] = $value
    }

    return $values
}

function ConvertTo-SecretPreview {
    param(
        [AllowNull()]
        [string]$Value
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return "<unset>"
    }

    if ($Value.Length -le 8) {
        return ("*" * $Value.Length)
    }

    return "{0}...{1}" -f $Value.Substring(0, 4), $Value.Substring($Value.Length - 4, 4)
}

function New-WorkflowResult {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [string]$Status,
        [Parameter(Mandatory = $true)]
        [string]$Reason
    )

    return [ordered]@{
        name = $Name
        status = $Status
        reason = $Reason
        details = [ordered]@{}
    }
}

function Invoke-NotionApi {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Method,
        [Parameter(Mandatory = $true)]
        [string]$Uri,
        [Parameter(Mandatory = $true)]
        [string]$ApiKey,
        [AllowNull()]
        $Body
    )

    $headers = @{
        "Authorization"  = "Bearer $ApiKey"
        "Notion-Version" = $notionVersion
    }

    if ($Method -in @("POST", "PATCH")) {
        $headers["Content-Type"] = "application/json"
    }

    if ($null -ne $Body) {
        return Invoke-RestMethod -Method $Method -Uri $Uri -Headers $headers -Body ($Body | ConvertTo-Json -Depth 15)
    }

    return Invoke-RestMethod -Method $Method -Uri $Uri -Headers $headers
}

function Invoke-NotionWorkflow {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$DotEnv,
        [Parameter(Mandatory = $true)]
        [bool]$StrictMode
    )

    $result = New-WorkflowResult -Name "notion_workflow" -Status "skipped" -Reason "notion_workflow_not_enabled"

    $apiKey = Get-EffectiveEnvValue -DotEnv $DotEnv -Name "NOTION_API_KEY"
    $databaseId = Get-EffectiveEnvValue -DotEnv $DotEnv -Name "NOTION_DATABASE_ID"
    $parentPageId = Get-EffectiveEnvValue -DotEnv $DotEnv -Name "NOTION_PARENT_PAGE_ID"
    $notionFlagRaw = Get-EffectiveEnvValue -DotEnv $DotEnv -Name "NAP_WORKFLOW_NOTION_ENABLED"

    $hasAnyNotionConfig = (-not [string]::IsNullOrWhiteSpace($apiKey)) -or (
        -not [string]::IsNullOrWhiteSpace($databaseId)
    ) -or (
        -not [string]::IsNullOrWhiteSpace($parentPageId)
    )

    $hasRequiredSecrets = (-not [string]::IsNullOrWhiteSpace($apiKey)) -and (
        (-not [string]::IsNullOrWhiteSpace($databaseId)) -or
        (-not [string]::IsNullOrWhiteSpace($parentPageId))
    )

    $enabledBy = "disabled"
    $notionEnabled = $false

    if ([string]::IsNullOrWhiteSpace($notionFlagRaw)) {
        if ($hasAnyNotionConfig) {
            $enabledBy = "auto_detect"
            $notionEnabled = $true
        }
    } else {
        $enabledBy = "explicit_flag"
        $notionEnabled = ConvertTo-Bool -Value $notionFlagRaw -Default $false
    }

    $result.details = [ordered]@{
        enabled_by = $enabledBy
        api_key = ConvertTo-SecretPreview -Value $apiKey
        has_database_id = -not [string]::IsNullOrWhiteSpace($databaseId)
        has_parent_page_id = -not [string]::IsNullOrWhiteSpace($parentPageId)
        notion_version = $notionVersion
    }

    if (-not $notionEnabled) {
        return $result
    }

    if ([string]::IsNullOrWhiteSpace($apiKey)) {
        $result.status = if ($StrictMode) { "fail" } else { "warn" }
        $result.reason = "notion_enabled_but_notion_api_key_missing"
        return $result
    }

    if ([string]::IsNullOrWhiteSpace($databaseId) -and [string]::IsNullOrWhiteSpace($parentPageId)) {
        $result.status = if ($StrictMode) { "fail" } else { "warn" }
        $result.reason = "notion_enabled_but_target_missing"
        return $result
    }

    try {
        $me = Invoke-NotionApi -Method "GET" -Uri "https://api.notion.com/v1/users/me" -ApiKey $apiKey -Body $null
        $result.details["workspace_probe"] = "ok"
        $result.details["workspace_user_type"] = $me.type
    } catch {
        $result.status = if ($StrictMode) { "fail" } else { "warn" }
        $result.reason = "notion_workspace_probe_failed"
        $result.details["error"] = $_.Exception.Message
        return $result
    }

    if (-not [string]::IsNullOrWhiteSpace($databaseId)) {
        try {
            $dbProbe = Invoke-NotionApi -Method "POST" -Uri ("https://api.notion.com/v1/databases/{0}/query" -f $databaseId) -ApiKey $apiKey -Body @{ page_size = 1 }
            $result.details["database_probe"] = "ok"
            $result.details["database_page_count_sample"] = if ($null -ne $dbProbe.results) { @($dbProbe.results).Count } else { 0 }
        } catch {
            $result.status = if ($StrictMode) { "fail" } else { "warn" }
            $result.reason = "notion_database_probe_failed"
            $result.details["error"] = $_.Exception.Message
            return $result
        }
    }

    if (-not [string]::IsNullOrWhiteSpace($parentPageId)) {
        try {
            $pageProbe = Invoke-NotionApi -Method "GET" -Uri ("https://api.notion.com/v1/pages/{0}" -f $parentPageId) -ApiKey $apiKey -Body $null
            $result.details["parent_page_probe"] = "ok"
            $result.details["parent_page_object"] = $pageProbe.object
        } catch {
            $result.status = if ($StrictMode) { "fail" } else { "warn" }
            $result.reason = "notion_parent_page_probe_failed"
            $result.details["error"] = $_.Exception.Message
            return $result
        }
    }

    $createHeartbeat = ConvertTo-Bool -Value (Get-EffectiveEnvValue -DotEnv $DotEnv -Name "NAP_WORKFLOW_NOTION_CREATE_HEARTBEAT") -Default $false
    if ($createHeartbeat -and -not [string]::IsNullOrWhiteSpace($databaseId)) {
        $heartbeatTitle = Get-EffectiveEnvValue -DotEnv $DotEnv -Name "NAP_WORKFLOW_NOTION_HEARTBEAT_TITLE"
        if ([string]::IsNullOrWhiteSpace($heartbeatTitle)) {
            $heartbeatTitle = "NAP Optional Workflow Heartbeat"
        }

        try {
            $databaseMeta = Invoke-NotionApi -Method "GET" -Uri ("https://api.notion.com/v1/databases/{0}" -f $databaseId) -ApiKey $apiKey -Body $null
            $titlePropertyName = $null

            foreach ($property in $databaseMeta.properties.PSObject.Properties) {
                if ($null -ne $property.Value -and $property.Value.type -eq "title") {
                    $titlePropertyName = $property.Name
                    break
                }
            }

            if ([string]::IsNullOrWhiteSpace($titlePropertyName)) {
                throw "No title property found in the target Notion database."
            }

            $propertiesPayload = @{}
            $propertiesPayload[$titlePropertyName] = @{
                title = @(
                    @{
                        text = @{
                            content = $heartbeatTitle
                        }
                    }
                )
            }

            $payload = @{
                parent = @{
                    database_id = $databaseId
                }
                properties = $propertiesPayload
                children = @(
                    @{
                        object = "block"
                        type = "paragraph"
                        paragraph = @{
                            rich_text = @(
                                @{
                                    type = "text"
                                    text = @{
                                        content = "Generated by tools/run_optional_workflows.ps1 on $(Get-Date -Format 'yyyy-MM-ddTHH:mm:ssK')."
                                    }
                                }
                            )
                        }
                    }
                )
            }

            $created = Invoke-NotionApi -Method "POST" -Uri "https://api.notion.com/v1/pages" -ApiKey $apiKey -Body $payload
            $result.details["heartbeat_created"] = $true
            $result.details["heartbeat_page_id"] = $created.id
            $result.details["heartbeat_title_property"] = $titlePropertyName
        } catch {
            $result.status = if ($StrictMode) { "fail" } else { "warn" }
            $result.reason = "notion_heartbeat_create_failed"
            $result.details["error"] = $_.Exception.Message
            return $result
        }
    } else {
        $result.details["heartbeat_created"] = $false
    }

    $result.status = "pass"
    $result.reason = "notion_workflow_completed"
    return $result
}

$dotEnv = Read-DotEnv -Path $EnvPath
$globalEnabled = ConvertTo-Bool -Value (Get-EffectiveEnvValue -DotEnv $dotEnv -Name "NAP_OPTIONAL_WORKFLOWS_ENABLED") -Default $false
$strictMode = $Strict.IsPresent -or (ConvertTo-Bool -Value (Get-EffectiveEnvValue -DotEnv $dotEnv -Name "NAP_OPTIONAL_WORKFLOWS_STRICT") -Default $false)

$workflowResults = @()

if ($globalEnabled) {
    $workflowResults += [pscustomobject](Invoke-NotionWorkflow -DotEnv $dotEnv -StrictMode $strictMode)
} else {
    $workflowResults += [pscustomobject](New-WorkflowResult -Name "notion_workflow" -Status "skipped" -Reason "optional_workflows_disabled")
}

$passCount = @($workflowResults | Where-Object { $_.status -eq "pass" }).Count
$skipCount = @($workflowResults | Where-Object { $_.status -eq "skipped" }).Count
$warnCount = @($workflowResults | Where-Object { $_.status -eq "warn" }).Count
$failCount = @($workflowResults | Where-Object { $_.status -eq "fail" }).Count

$overallStatus = "pass"
if ($failCount -gt 0) {
    $overallStatus = "fail"
} elseif ($warnCount -gt 0) {
    $overallStatus = "warn"
}

$report = [ordered]@{
    metadata = [ordered]@{
        generated_at_utc = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        script_version = $scriptVersion
        env_path = $EnvPath
    }
    config = [ordered]@{
        optional_workflows_enabled = $globalEnabled
        strict_mode = $strictMode
    }
    summary = [ordered]@{
        status = $overallStatus
        workflow_count = @($workflowResults).Count
        pass_count = $passCount
        warn_count = $warnCount
        fail_count = $failCount
        skip_count = $skipCount
    }
    workflows = $workflowResults
}

$outputDir = Split-Path -Path $OutputPath -Parent
if ($outputDir -and -not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

$report | ConvertTo-Json -Depth 15 | Set-Content -Path $OutputPath -Encoding UTF8

Write-Host "Optional workflow report written to $OutputPath"
Write-Host "Pass: $passCount, Warn: $warnCount, Fail: $failCount, Skipped: $skipCount"

if ($strictMode -and ($failCount -gt 0 -or $warnCount -gt 0)) {
    exit 2
}

if ($failCount -gt 0) {
    exit 2
}

exit 0
