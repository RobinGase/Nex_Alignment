# Use-Case Playbooks Index

This index maps each profile to a deterministic starting bundle of protocol documents.

Canonical profile metadata remains in:

- `../profiles/use_case_profiles.yaml`
- `../profiles/use_case_bundles.yaml`

## Profile playbooks

| Profile | Minimum Risk | Autonomy Ceiling | First docs to read |
| --- | ---: | --- | --- |
| `website_frontend` | 1 | A2 | `../core/README.md`, `../runtime/use_case_profile_framework.md`, `../safety/testing_and_verification.md` |
| `database_operations` | 2 | A2 | `../core/README.md`, `../core/configuration_and_risk_management.md`, `../runtime/README.md` |
| `payments_transfers` | 3 | A2 | `../runtime/README.md`, `../evaluation/economic_and_performance_risk_modeling.md`, `../safety/risk_acceptance_and_residuals.md` |
| `ai_stack_training_inference` | 2 | A3 | `../core/README.md`, `../safety/ai_specific_considerations.md`, `../safety/model_and_data_supply_chain_security.md` |
| `data_pipeline_etl` | 2 | A2 | `../core/README.md`, `../core/configuration_and_risk_management.md`, `../core/traceability_and_documentation.md` |
| `api_backend_services` | 2 | A2 | `../core/README.md`, `../core/architecture_design.md`, `../runtime/README.md` |
| `infrastructure_devops` | 2 | A2 | `../runtime/README.md`, `../safety/operations_and_maintenance.md`, `../runtime/telemetry_schema.md` |
| `security_incident_response` | 3 | A3 | `../safety/README.md`, `../runtime/README.md`, `../safety/risk_acceptance_and_residuals.md` |
| `healthcare_clinical_ai` | 4 | A2 | `../safety/README.md`, `../safety/formal_verification_and_runtime_proof.md`, `../runtime/compliance_runtime_spec.md` |
| `legal_advice_generation` | 3 | A2 | `../safety/README.md`, `../safety/ai_specific_considerations.md`, `../safety/testing_and_verification.md` |
| `identity_kyc_auth` | 3 | A2 | `../core/README.md`, `../safety/model_and_data_supply_chain_security.md`, `../runtime/README.md` |
| `third_party_integration` | 2 | A2 | `../core/README.md`, `../evaluation/federated_governance_and_interoperability.md`, `../runtime/README.md` |

## Required execution checks

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_use_case_profiles.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tools/check_policy_runtime_parity.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tools/run_enforcement_simulations.ps1
```
