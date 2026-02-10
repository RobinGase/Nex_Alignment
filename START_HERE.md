# NAP Start Here: Use-Case Router

Use this page as the main entry point for both developers and agents.
It routes work to the correct folders and protocol documents by use case.

## 1. Fast path (required)

1. Pick a use-case profile from `profiles/use_case_profiles.yaml`.
2. Read profile rules in `runtime/use_case_profile_framework.md`.
3. Fill `templates/task_header_template.md` with profile + operation tags.
4. Set risk/autonomy using:
 - `core/risk_classification.md`
 - `core/agent_autonomy_and_human_oversight.md`
5. Enforce runtime rules with:
 - `runtime/compliance_runtime_spec.md`
 - `runtime/unified_governance_decision_model.md`

## 2. Folder routing map

| Folder | Use it for | First file to open |
| --- | --- | --- |
| `core/` | Core protocol baseline and lifecycle foundation. | `core/README.md` |
| `safety/` | Hazard, verification, and assurance-first controls. | `safety/README.md` |
| `runtime/` | Runtime decision ownership and enforcement path. | `runtime/README.md` |
| `evaluation/` | Advisory evaluation harnesses and audit context. | `evaluation/README.md` |
| `use_case_playbooks/` | Profile-by-profile execution starting points. | `use_case_playbooks/README.md` |
| `maps/` | Machine-readable routing assets for agents and tooling. | `maps/README.md` |
| `profiles/` | Select domain profile and required bundles. | `profiles/use_case_profiles.yaml` |
| `templates/` | Start task artifacts and override requests. | `templates/task_header_template.md` |
| `tools/` | Validate profile consistency, policy parity, and simulations. | `tools/validate_use_case_profiles.ps1` |
| `audit_outputs/` | Read generated machine reports. | `audit_outputs/README.md` |

## 3. Use-case to protocol route

| Use case | Primary profile | Core docs to read first |
| --- | --- | --- |
| Website and UI work | `website_frontend` | `runtime/use_case_profile_framework.md`, `safety/testing_and_verification.md`, `safety/runtime_behavioral_contracts.md` |
| Database changes | `database_operations` | `core/configuration_and_risk_management.md`, `core/traceability_and_documentation.md`, `runtime/compliance_runtime_spec.md` |
| Payments and transfers | `payments_transfers` | `evaluation/economic_and_performance_risk_modeling.md`, `safety/risk_acceptance_and_residuals.md`, `runtime/compliance_runtime_spec.md` |
| AI training and inference | `ai_stack_training_inference` | `safety/ai_specific_considerations.md`, `safety/model_and_data_supply_chain_security.md`, `safety/runtime_behavioral_contracts.md` |
| Data pipelines and ETL | `data_pipeline_etl` | `core/configuration_and_risk_management.md`, `safety/model_and_data_supply_chain_security.md`, `core/trace_graph_schema.md` |
| API/backend services | `api_backend_services` | `core/architecture_design.md`, `safety/testing_and_verification.md`, `runtime/enforcement_and_policy_engine.md` |
| Infrastructure and DevOps | `infrastructure_devops` | `safety/operations_and_maintenance.md`, `runtime/enforcement_architecture_and_implementation.md`, `runtime/telemetry_schema.md` |
| Security incident response | `security_incident_response` | `runtime/enforcement_and_policy_engine.md`, `runtime/telemetry_schema.md`, `safety/risk_acceptance_and_residuals.md` |
| Healthcare clinical AI | `healthcare_clinical_ai` | `safety/formal_verification_and_runtime_proof.md`, `safety/safety_and_assurance.md`, `runtime/compliance_runtime_spec.md` |
| Legal advice generation | `legal_advice_generation` | `safety/ai_specific_considerations.md`, `safety/testing_and_verification.md`, `safety/runtime_behavioral_contracts.md` |
| Identity, KYC, and auth | `identity_kyc_auth` | `safety/model_and_data_supply_chain_security.md`, `core/traceability_and_documentation.md`, `runtime/enforcement_and_policy_engine.md` |
| Third-party integration | `third_party_integration` | `evaluation/federated_governance_and_interoperability.md`, `safety/model_and_data_supply_chain_security.md`, `runtime/compliance_runtime_spec.md` |

## 4. Required checks before merge/release

Run all three:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_use_case_profiles.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tools/check_policy_runtime_parity.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tools/run_enforcement_simulations.ps1
```

Then review:

- `audit_outputs/use_case_profile_validation_report.json`
- `audit_outputs/policy_runtime_parity_report.json`
- `audit_outputs/executable_simulation_results.json`

## 5. Optional workflow integrations (env-driven)

If you want optional external tool-calls (for example Notion), configure `.env` from `.env.example` and run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/run_optional_workflows.ps1
```

Review:

- `audit_outputs/optional_workflow_results.json`

## 6. Decision authority reminder

To avoid double-divination:

1. Runtime decisions are owned by `runtime/compliance_runtime_spec.md` + `runtime/unified_governance_decision_model.md`.
2. Harness docs are advisory and do not independently authorize release.

## 7. Optional machine routing

For automated agents and CI routing, use:

- `maps/use_case_doc_routes.yaml`

