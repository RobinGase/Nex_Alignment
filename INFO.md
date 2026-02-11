# Project Information

## Purpose
NexGentic Agents Protocol is a governance framework for designing, evaluating, and operating AI agent systems with deterministic safety and enforcement controls.

## Repository Structure
The repository is organized into four canonical protocol domains.

1. `core/` for risk classification, requirements, architecture, and traceability.
2. `safety/` for hazard analysis, testing, assurance, and runtime behavioral constraints.
3. `runtime/` for policy enforcement, decision contracts, telemetry, and governance scoring.
4. `evaluation/` for multi-lens audits, probabilistic assurance methods, and strategic resilience models.

Additional supporting directories.

1. `profiles/` for use-case profile catalogs and bundle definitions.
2. `templates/` for operational and governance artifacts.
3. `tools/` for validation and enforcement simulation scripts.
4. `maps/` and `use_case_playbooks/` for routing and implementation guidance.
5. `audit_outputs/` for generated validation reports.

## Start Sequence
1. Open `.AppName/APPNAME.md`.
2. Select a use-case profile.
3. Declare risk class and autonomy tier.
4. Complete required templates.
5. Run validation scripts from `tools/`.

## Validation Commands
Run the following commands before publishing or release.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_use_case_profiles.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tools/check_policy_runtime_parity.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tools/run_enforcement_simulations.ps1
```

## Optional Integration Command
If optional external workflows are enabled in `.env`, run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/run_optional_workflows.ps1
```

## Decision Ownership
Runtime authorization is owned by.

1. `runtime/compliance_runtime_spec.md`
2. `runtime/unified_governance_decision_model.md`

Audit harness outputs are advisory and do not independently authorize runtime actions.
