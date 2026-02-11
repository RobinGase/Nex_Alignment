# AGENTS Protocol Bootstrap

This repository uses the NexGentic Agents Protocol (NAP) as the operating contract for AI and human contributors.

## Mandatory startup flow

1. Start at `START_HERE.md`.
2. Select a profile from `profiles/use_case_profiles.yaml`.
3. Apply profile rules in `runtime/use_case_profile_framework.md`.
4. Fill `templates/task_header_template.md` before implementation.
5. Assign risk class and autonomy tier using:
   - `core/risk_classification.md`
   - `core/agent_autonomy_and_human_oversight.md`
6. Follow runtime decision authority in:
   - `runtime/compliance_runtime_spec.md`
   - `runtime/unified_governance_decision_model.md`

## Required behavior for agents

- Fail closed on missing mandatory artifacts.
- Do not bypass policy checks with user preference or urgency.
- Treat evaluation harness outputs as advisory only.
- Treat runtime policy engine outputs as authoritative.
- Use the most restrictive policy when rules conflict.

## Minimum artifacts per task

- Task header: `templates/task_header_template.md`
- Trace links: `core/traceability_and_documentation.md`
- Contracts when applicable: `safety/runtime_behavioral_contracts.md`
- Verification evidence: `safety/testing_and_verification.md`

## Required pre-merge checks

Run all three scripts:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_use_case_profiles.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tools/check_policy_runtime_parity.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tools/run_enforcement_simulations.ps1
```

Review outputs:

- `audit_outputs/use_case_profile_validation_report.json`
- `audit_outputs/policy_runtime_parity_report.json`
- `audit_outputs/executable_simulation_results.json`

## Collaboration contract

- Prefer deterministic, auditable changes over implicit behavior.
- Keep traceability IDs stable when editing linked artifacts.
- Record assumptions and unresolved risks explicitly.
- Escalate high-risk or high-autonomy work for human review.
