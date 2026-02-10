# Quick Test Verification (No Pester Required)
# This script manually verifies core functionality without requiring Pester framework

$ErrorActionPreference = "Stop"

Write-Host "=== Quick Test Verification ===" -ForegroundColor Cyan
Write-Host ""

# Source the validation script
. "$PSScriptRoot/../validate_use_case_profiles.ps1"

$results = @()

# Test 1: Get-AutonomyRank with valid tiers
Write-Host "Test 1: Get-AutonomyRank - Valid tiers" -ForegroundColor Yellow
$validTiers = @(
    @{ Tier = "A0"; Expected = 0 },
    @{ Tier = "A1"; Expected = 1 },
    @{ Tier = "A2"; Expected = 2 },
    @{ Tier = "A3"; Expected = 3 },
    @{ Tier = "A4"; Expected = 4 }
)

$passed = 0
$failed = 0
foreach ($test in $validTiers) {
    $result = Get-AutonomyRank -Tier $test.Tier
    if ($result -eq $test.Expected) {
        Write-Host "  OK $($test.Tier) => $result" -ForegroundColor Green
        $passed++
    } else {
        Write-Host "  FAIL $($test.Tier) => $result (expected $($test.Expected))" -ForegroundColor Red
        $failed++
    }
}
Write-Host "  Result: $passed passed, $failed failed" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Red" })
$results += @{ Test = "Get-AutonomyRank (valid)"; Passed = ($passed -eq 5) }
Write-Host ""

# Test 2: Get-AutonomyRank with invalid tiers (case-insensitive matching)
Write-Host "Test 2: Get-AutonomyRank - Invalid tiers" -ForegroundColor Yellow
$invalidTiers = @("A5", "B1", "A02", "A10", "ZZZ")

$passed = 0
$failed = 0
foreach ($tier in $invalidTiers) {
    $result = Get-AutonomyRank -Tier $tier
    if ($result -eq -1) {
        Write-Host "  OK '$tier' => -1 (correctly invalid)" -ForegroundColor Green
        $passed++
    } else {
        Write-Host "  FAIL '$tier' => $result (expected -1)" -ForegroundColor Red
        $failed++
    }
}
Write-Host "  Result: $passed passed, $failed failed" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Red" })
$results += @{ Test = "Get-AutonomyRank (invalid)"; Passed = ($passed -eq 5) }
Write-Host ""

# Test 2b: Get-AutonomyRank - case-insensitive matching
Write-Host "Test 2b: Get-AutonomyRank - Case-insensitive valid tiers" -ForegroundColor Yellow
$lowercaseTiers = @(@{ Tier = "a0"; Expected = 0 }, @{ Tier = "a2"; Expected = 2 }, @{ Tier = "a4"; Expected = 4 })

$passed = 0
$failed = 0
foreach ($test in $lowercaseTiers) {
    $result = Get-AutonomyRank -Tier $test.Tier
    if ($result -eq $test.Expected) {
        Write-Host "  OK '$($test.Tier)' => $result (case-insensitive match)" -ForegroundColor Green
        $passed++
    } else {
        Write-Host "  FAIL '$($test.Tier)' => $result (expected $($test.Expected))" -ForegroundColor Red
        $failed++
    }
}
Write-Host "  Result: $passed passed, $failed failed" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Red" })
$results += @{ Test = "Get-AutonomyRank (case-insensitive)"; Passed = ($passed -eq 3) }
Write-Host ""

# Test 3: Get-ListFromBlock extraction
Write-Host "Test 3: Get-ListFromBlock - List extraction" -ForegroundColor Yellow
$testBlock = @'
key1:
  - item1
  - item2
  - item3
key2:
  - should-not-include
'@

$items = Get-ListFromBlock -Block $testBlock -Key "key1"
if ($items.Count -eq 3 -and $items[0] -eq "item1" -and $items[2] -eq "item3") {
    Write-Host "  OK Extracted 3 items correctly: $($items -join ', ')" -ForegroundColor Green
    $results += @{ Test = "Get-ListFromBlock"; Passed = $true }
} else {
    Write-Host "  FAIL Extraction failed or incorrect" -ForegroundColor Red
    Write-Host "    Result: $($items.Count) items - $($items -join ', ')" -ForegroundColor Red
    $results += @{ Test = "Get-ListFromBlock"; Passed = $false }
}
Write-Host ""

# Test 4: Parse real profile catalog
Write-Host "Test 4: Parse real profile catalog" -ForegroundColor Yellow
$profilesPath = "$PSScriptRoot/../../profiles/use_case_profiles.yaml"
if (Test-Path $profilesPath) {
    try {
        $catalog = Get-ProfileCatalog -Path $profilesPath
        if ($catalog.profiles.Count -eq 12) {
            Write-Host "  OK Parsed $($catalog.profiles.Count) profiles" -ForegroundColor Green
            Write-Host "  OK Version: $($catalog.version)" -ForegroundColor Green

            $allValid = $true
            foreach ($profile in $catalog.profiles) {
                if ($profile.min_risk_class -lt 0 -or $profile.min_risk_class -gt 4) {
                    Write-Host "  FAIL Profile '$($profile.id)' has invalid min_risk_class: $($profile.min_risk_class)" -ForegroundColor Red
                    $allValid = $false
                }
                if ((Get-AutonomyRank -Tier $profile.autonomy_ceiling) -lt 0) {
                    Write-Host "  FAIL Profile '$($profile.id)' has invalid autonomy_ceiling: $($profile.autonomy_ceiling)" -ForegroundColor Red
                    $allValid = $false
                }
            }
            if ($allValid) {
                Write-Host "  OK All profiles have valid risk class and autonomy ceiling" -ForegroundColor Green
                $results += @{ Test = "Parse profiles"; Passed = $true }
            } else {
                $results += @{ Test = "Parse profiles"; Passed = $false }
            }
        } else {
            Write-Host "  FAIL Expected 12 profiles, got $($catalog.profiles.Count)" -ForegroundColor Red
            $results += @{ Test = "Parse profiles"; Passed = $false }
        }
    } catch {
        Write-Host "  FAIL Error parsing profiles: $_" -ForegroundColor Red
        $results += @{ Test = "Parse profiles"; Passed = $false }
    }
} else {
    Write-Host "  FAIL Profile catalog not found at $profilesPath" -ForegroundColor Red
    $results += @{ Test = "Parse profiles"; Passed = $false }
}
Write-Host ""

# Test 5: Parse real bundle catalog
Write-Host "Test 5: Parse real bundle catalog" -ForegroundColor Yellow
$bundlesPath = "$PSScriptRoot/../../profiles/use_case_bundles.yaml"
if (Test-Path $bundlesPath) {
    try {
        $catalog = Get-BundleCatalog -Path $bundlesPath
        if ($catalog.bundles.Count -eq 10) {
            Write-Host "  OK Parsed $($catalog.bundles.Count) bundles" -ForegroundColor Green
            Write-Host "  OK Version: $($catalog.version)" -ForegroundColor Green
            $results += @{ Test = "Parse bundles"; Passed = $true }
        } else {
            Write-Host "  FAIL Expected 10 bundles, got $($catalog.bundles.Count)" -ForegroundColor Red
            $results += @{ Test = "Parse bundles"; Passed = $false }
        }
    } catch {
        Write-Host "  FAIL Error parsing bundles: $_" -ForegroundColor Red
        $results += @{ Test = "Parse bundles"; Passed = $false }
    }
} else {
    Write-Host "  FAIL Bundle catalog not found at $bundlesPath" -ForegroundColor Red
    $results += @{ Test = "Parse bundles"; Passed = $false }
}
Write-Host ""

# Summary
Write-Host "=== Test Summary ===" -ForegroundColor Cyan
$totalResults = $results.Count
$passedTests = ($results | Where-Object { $_.Passed }).Count
Write-Host "Total: $totalResults tests run, Passed: $passedTests, Failed: $($totalResults - $passedTests)" -ForegroundColor $(if ($passedTests -eq $totalResults) { "Green" } else { "Red" })
Write-Host ""

foreach ($result in $results) {
    if ($result.Passed) {
        Write-Host "  OK $($result.Test)" -ForegroundColor Green
    } else {
        Write-Host "  FAIL $($result.Test)" -ForegroundColor Red
    }
}

if ($passedTests -eq $totalResults) {
    Write-Host ""
    Write-Host "All tests passed!" -ForegroundColor Green
    exit 0
} else {
    Write-Host ""
    Write-Host "Some tests failed!" -ForegroundColor Red
    exit 1
}
