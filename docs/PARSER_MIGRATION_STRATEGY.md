# Parser Migration Strategy

## Context

The current PowerShell validation tools use regex-based YAML parsing (`Get-ListFromBlock` function across all four scripts). This approach is functional but has fragility risks:
- Sensitive to formatting changes
- Higher maintenance burden for edge cases
- No formal YAML schema validation

This document defines the strategy and trigger criteria for migrating to a parser-based YAML approach.

## Migration Trigger Criteria

Execute parser migration (Phase 4B) if **ANY** of the following conditions are met:

### Criterion 1: Regex-Related Test Failures
- Trigger: >5 regex-related test failures per year
- Rationale: Indicator of fragility and maintenance burden
- Tracking: Tag test failures with "regex-parsing" category

### Criterion 2: New YAML Features Required
- Trigger: New YAML features required that regex parsing cannot handle:
  - Multi-line values with complex escape sequences
  - YAML anchors and aliases (`&anchor`, `*alias`)
  - Flow-style mappings (`{ key: value }`)
  - Complex nested structures
- Rationale: Regex cannot reliably parse these constructs
- Tracking: Feature request documentation

### Criterion 3: Maintenance Cost Threshold
- Trigger: Team effort spent on regex parsing maintenance exceeds **40 hours/year**
- Activities included:
  - Regex pattern debugging
  - Test failures related to YAML edge cases
  - Workarounds for formatting-sensitive parsing
  - Documentation updates for parsing quirks
- Rationale: At this cost, migration investment is justified
- Tracking: Time tracking with "yaml-parsing-maintenance" tag

**Technical Debt Accumulation Cost Tracking:**

| Year | Regex Bug Fixes | Regex Test Failures | Edge Case Workarounds | Total Hours | Trigger Met? |
|------|----------------|-------------------|----------------------|-------------|--------------|
| 2026 | - | - | - | 0 | No |
| 2027 | TBD | TBD | TBD | TBD | TBD |

## Migration Options

When trigger criteria are met, choose one of the following migration paths:

### Option A (Recommended): PowerShell 7+ `ConvertFrom-Yaml` Cmdlet

**Pros:**
- Built-in PowerShell 7+ (no external dependency)
- Minimal code changes required
- Cross-platform (works on Linux/macOS via pwsh)

**Cons:**
- Requires PowerShell 7+ runtime
- Less feature-rich than dedicated libraries

**Implementation Steps:**
1. Verify target environments support PowerShell 7+
2. Replace `Get-ListFromBlock` with `ConvertFrom-Yaml` calls
3. Update type casting for parsed objects
4. Run Pester tests to ensure parity with regex version
5. Performance regression testing (parser should not be slower)

**Estimated Effort:** 15-20 hours

### Option B: YamlDotNet NuGet Package

**Pros:**
- Full-featured YAML 1.2 support
- Handles complex YAML constructs
- Mature library with active development

**Cons:**
- External dependency (requires module installation)
- Additional deployment complexity
- Larger memory footprint

**Implementation Steps:**
1. Create `tools/powershell_modules/` directory
2. Install `YamlDotNet` module: `Install-Module -Name YamlDotNet`
3. Write wrapper functions maintaining existing signatures
4. Update all 4 validation scripts to use YamlDotNet parser
5. Document dependency installation for users
6. Run Pester tests for parity

**Estimated Effort:** 20-25 hours

### Option C: Full Python Migration

**Pros:**
- Native cross-platform compatibility
- PyYAML is mature and feature-rich
- Enables Linux/macOS adoption without PowerShell dependency

**Cons:**
- Highest migration effort
- Requires creating Python equivalents for all validation logic
- Breaking change for existing Windows PowerShell users
- Dual maintenance during transition period

**Implementation Steps:**
1. Migrate all 4 PowerShell validation scripts to Python 3.8+
2. Use `PyYAML` library for parsing (`import yaml`)
3. Maintain identical validation logic and output JSON formats
4. Create migration guide for existing users
5. Deprecate PowerShell scripts gradually
6. Update CI workflows to support both languages

**Estimated Effort:** 30-40 hours

## Rollback Plan

If parser migration causes issues:

### Immediate Rollback
1. Revert to previous commit (regex-based version is preserved in git history)
2. Run Pester tests to confirm expected behavior
3. Document rollback cause in CHANGELOG.md

### Documentation Update
Update `docs/MIGRATION_PATH_UPDATE.md` with:
- Parser migration rollback procedure
- Known issue that caused rollback
- Alternative mitigation strategies

### Communication
Notify users via:
- CHANGELOG.md entry with rollback note
- Issue tracker if migration caused user problems

## Recommendation

**Default Path: Option A (PowerShell 7+ `ConvertFrom-Yaml`)**

This option balances:
- Minimal implementation effort (15-20 hours)
- No external dependencies
- Cross-platform compatibility via pwsh
- Low user impact (PowerShell 7+ is widely available)

**Contingency Path:**
- If PowerShell 7+ availability is problematic → **Option B (YamlDotNet)**
- If full deprecation of PowerShell is desired → **Option C (Python)**

## Next Steps

When Phase 4B is triggered:

1. Review migration options and select based on environment constraints
2. Create migration branch from `main`
3. Implement selected parser migration
4. Run comprehensive Pester test suite (>80% coverage)
5. Performance regression testing
6. Cross-validation with existing audit outputs (results must match)
7. Update documentation (scripts, README.md, migration guide)
8. PR review and merge to `main`
9. Tag release and update CHANGELOG.md

---

**Document Version:** 1.0.0
**Created:** 2026-02-10
**Related:** LLM_Review/Implementation_plan/PLAN.md Phase 4.2 & 4B
