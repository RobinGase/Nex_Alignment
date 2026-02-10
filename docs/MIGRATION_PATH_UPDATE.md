# Migration: Path Default Updates (v1.1.2 -> v1.1.3)

## Breaking Change
PowerShell scripts now use `$PSScriptRoot`-relative path defaults instead of hardcoded `NexGentic_Agents_Protocol/...` prefixes.

## Impact on Existing Users
If you have hardcoded script calls like:

```powershell
.\tools\validate_use_case_profiles.ps1 -ProfilesPath "NexGentic_Agents_Protocol/profiles/use_case_profiles.yaml"
```

Your workflow may still work when the explicit path is valid, but it is now recommended to use repo-relative defaults.

## Migration Options

### Option 1: Use Explicit Paths (No Change Required)
Continue passing explicit paths. Existing workflows will work unchanged when paths remain valid.

### Option 2: Remove Hardcoded Paths (Recommended)
Update workflows to omit path parameters and rely on the new defaults:

```powershell
.\tools\validate_use_case_profiles.ps1
```

### Option 3: Update Your Fork
If you maintain a fork with custom path conventions, update script defaults to match:

```powershell
[string]$ProfilesPath = (Join-Path $PSScriptRoot "..\profiles\use_case_profiles.yaml")
```

## Rollback
If you encounter migration issues:

1. Temporarily run scripts with explicit `-ProfilesPath`, `-BundlesPath`, `-RulesPath`, `-EnvPath`, and `-OutputPath` parameters.
2. Revert your fork to `v1.1.2` behavior if needed while planning migration.
3. Reapply `v1.1.3` once defaults and automation paths are verified in your environment.
