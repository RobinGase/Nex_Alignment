# Pester Test Execution Guide

## Prerequisites

PowerShell Core (pwsh) 7+ is recommended for cross-platform testing. Pester 5+ is required for running the test suite.

### Install Pester (PowerShell 7+)

```powershell
# For Windows/macOS/Linux with pwsh
Install-Module -Name Pester -MinimumVersion 5.0 -Force -Scope CurrentUser
```

### Install Pester (Windows PowerShell 5.1)

```powershell
# Requires PowerShell 5.1
Install-Module -Name Pester -MinimumVersion 5.0 -Force -Scope CurrentUser
```

## Running Tests

### Run All Tests

```powershell
# From repository root
Invoke-Pester -Path tools/tests -Output Detailed
```

### Run Specific Test File

```powershell
# Test Get-ListFromBlock function
Invoke-Pester -Path tools/tests/Test-GetListFromBlock.ps1 -Output Detailed

# Test Get-AutonomyRank function
Invoke-Pester -Path tools/tests/Test-AutonomyRank.ps1 -Output Detailed

# Test profile validation logic
Invoke-Pester -Path tools/tests/Test-ProfileValidation.ps1 -Output Detailed
```

### Run Tests with Coverage Report

```powershell
# Generate code coverage report
Invoke-Pester -Path tools/tests `
    -CodeCoverage ./tools/validate_use_case_profiles.ps1 `
    -CoveragePercentTarget 80
```

## Test Coverage

- **Test-GetListFromBlock.ps1**: Tests regex-based YAML list extraction
  - Valid list extraction (single/multi-item)
  - Whitespace and special character handling
  - Empty and edge cases
  - Multi-line values
  - Unicode character handling

- **Test-AutonomyRank.ps1**: Tests autonomy tier to numeric rank conversion
  - Valid tiers (A0-A4)
  - Invalid tiers (null, empty, out of range)
  - Case sensitivity enforcement

- **Test-ProfileValidation.ps1**: Tests profile and bundle catalog validation
  - Profile structure parsing
  - Bundle structure parsing
  - Validation rules (risk class, autonomy ceiling, required bundles)
  - Cross-reference validation (unknown bundles, duplicates)

## Fixtures

Test fixtures are located in `tools/tests/fixtures/`:
- `valid_profile.yaml` - Valid profile structure with 2 test profiles
- `valid_bundles.yaml` - Valid bundle structure with 3 test bundles

## CI Integration

The Pester tests can be integrated into CI workflows:

### GitHub Actions

```yaml
- name: Run Pester tests
  shell: pwsh
  run: Invoke-Pester -Path tools/tests -Output Detailed
```

### GitLab CI

```yaml
- pwsh -Command "Invoke-Pester -Path tools/tests -Output Detailed"
```

## Expected Results

When all tests pass:
- Get-ListFromBlock: All list extraction tests pass
- Get-AutonomyRank: Valid tiers return correct ranks, invalid tiers return -1
- ProfileValidation: All validation logic tests pass

Test failures indicate regression in validation logic or edge case handling.
