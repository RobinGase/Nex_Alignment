# Minimal Compliance Runtime Specification

This document defines a deterministic enforcement contract for the NexGentic Agents Protocol (NAP). It converts governance rules into executable runtime checks for CI/CD and production policy engines.

## 0. Decision authority, precedence, and terminology (normative)

To avoid duplicate gates and semantic drift:

1. Runtime authorization owners: `runtime/compliance_runtime_spec.md` and `runtime/unified_governance_decision_model.md`.
2. Audit owners (non-authorizing): `evaluation/nap_evaluation_harness.md` and `evaluation/multi_lens_evaluation_harness.md`.
3. Health scoring owner (input only): `runtime/compliance_scoring_and_metrics.md`.
4. Policy template role: `templates/policy_engine_rules.yaml` configures checks but does not own final runtime outcomes.

### Canonical decision terminology

| Term | Meaning | Authoritative owner |
|---|---|---|
| `approve` | Transition or release is automatically permitted. | Runtime authorization owners |
| `manual_review` | Human reviewer decision is required. | Runtime authorization owners |
| `block` | Transition or release is denied until remediation. | Runtime authorization owners |
| `escalate` | Decision routed to governance authority due to severity or conflict. | Runtime authorization owners |
| `warn` | Advisory telemetry signal only; no independent high-risk authorization effect. | Runtime authorization owners |
| `assurance_go` | Audit readiness recommendation only. | Audit owners |
| `assurance_no_go` | Audit readiness failure recommendation only. | Audit owners |

### Precedence model

When signals conflict, policy engines MUST apply this order:

1. Hard fail checks first: missing or invalid mandatory artifacts, integrity failures, unknown profile IDs, or composite profile conflicts force `block`/`escalate`.
2. Profile floor and ceiling checks second: verify use-case profile compatibility before score-based outcomes.
3. Runtime score third: compute outcome using `runtime/unified_governance_decision_model.md`.
4. Conservative tie-break: `escalate > block > manual_review > approve`.
5. Advisory signals last: audit outcomes and health scores may trigger actions but cannot override runtime authorization.

## 1. State machine and gating logic

NAP uses a seven-state lifecycle:

`INIT -> PLAN -> READ -> CHANGE -> VERIFY -> REVIEW -> RELEASE`

Each state transition is gated by the policy engine and evaluated against risk class, autonomy tier, and use-case profile constraints.

| State | Class 0-1 | Class 2 | Class 3 | Class 4 |
|---|---|---|---|---|
| PLAN | Task header with goal, assumptions, and plan | + Requirements document | + Hazard log draft | + Formal design document and hazard log draft |
| READ | - | - | Architecture design summary | Architecture design document and risk assessment |
| CHANGE | Unit tests | Unit and integration tests | Unit, integration, and system tests; behavioral contract definitions | All tests plus formal contract specifications |
| VERIFY | Test results | + Traceability matrix + preliminary hazard log verified | + Hazard controls verified, IV&V report | + Independent test reports and proof artifacts |
| REVIEW | Peer review | + Risk reviewer sign-off | + Independent safety review | + IV&V and safety board approval |
| RELEASE | Automated release notes | + Risk owner approval | + Signed residual risk acceptance | + Board approval and external regulator sign-off |

Notes:

1. Autonomy tiers A2-A4 require human approval at REVIEW and RELEASE, regardless of risk class.
2. A4 is prohibited for Class 0-2 and allowed for Class 3-4 only with exceptional controls.
3. Profile declaration is mandatory for Class 2-4 and strongly recommended for Class 0-1.

## 2. Artifact validation rules

Evidence validation MUST enforce:

1. Existence: mandatory artifacts exist and use unique IDs.
2. Completeness: required fields are populated.
3. Signatures: artifact signatures are valid.
4. Traceability: artifacts are linked in the trace graph.
5. Version consistency: artifact and policy versions are compatible.

Validators return machine-readable missing and invalid artifact lists.

## 3. Use-case profile layer (normative)

Profile catalogs:

- `profiles/use_case_profiles.yaml`
- `profiles/use_case_bundles.yaml`

Verification rules:

1. `primary_use_case_profile` MUST exist for Class 2-4 tasks.
2. Up to two secondary profiles are allowed.
3. Effective profile set is the unique union of declared profiles.
4. Effective bundle set is the union of required bundles across the effective profile set.
5. Effective minimum risk floor is the max profile floor.
6. Effective autonomy ceiling is the most restrictive profile ceiling.
7. `highest-safety-wins` resolves conflicts.
8. Operation tags MUST be compatible with selected profiles.

Decision handling:

1. Unknown profile ID: `block`.
2. Composite profile conflict: `block` and emit incident artifact.
3. Profile mismatch for Class 2-4: `block`.
4. Profile mismatch for Class 0-1: `manual_review`.

Overrides:

1. Overrides are allowed for reference-level controls only.
2. Immutable constraints are non-waivable.
3. Overrides require rationale, compensating controls, approver, and expiry.
4. Expired or incomplete overrides force `block`.

## 4. Policy engine input/output schema

Define a machine-readable request/response contract.

### Policy Evaluation Request

```json
{
 "task_id": "TASK-123",
 "risk_class": 3,
 "autonomy_tier": "A2",
 "current_state": "VERIFY",
 "primary_use_case_profile": "payments_transfers",
 "secondary_use_case_profiles": ["third_party_integration"],
 "operation_tags": ["currency_transfer", "settlement"],
 "profile_version": "1.0.0",
 "override_ids": ["OVR-2026-001"],
 "artifacts": [
 {"id": "REQ-1", "type": "requirement"},
 {"id": "TST-5", "type": "test"},
 {"id": "HAZ-2", "type": "hazard"},
 {"id": "TRACE-GRAPH-1", "type": "trace_graph"}
 ]
}
```

### Policy Evaluation Response

```json
{
 "task_id": "TASK-123",
 "allowed": false,
 "current_state": "VERIFY",
 "next_state": null,
 "profile_verdict": "mismatch",
 "effective_profile_set": ["payments_transfers", "third_party_integration"],
 "effective_bundle_set": [
 "B01_CORE_GOV",
 "B02_CHANGE_DATA_INTEGRITY",
 "B04_FINANCIAL_TRANSACTION_CONTROL",
 "B05_PRIVACY_REGULATED_DATA",
 "B06_RUNTIME_CONTAINMENT",
 "B07_AI_MODEL_SUPPLY_CHAIN",
 "B09_SECURITY_INCIDENT_FORENSICS",
 "B10_INTEROP_FEDERATION"
 ],
 "profile_violation_reasons": [
 "risk_class_below_effective_floor"
 ],
 "missing_artifacts": ["HAZ-LOG"],
 "invalid_artifacts": [],
 "message": "Profile floor and artifact requirements not satisfied."
}
```

Response field notes:

1. `profile_verdict`: `match | mismatch | ambiguous`.
2. `effective_profile_set`: resolved primary and secondary profiles.
3. `effective_bundle_set`: union bundle set from selected profiles.
4. `profile_violation_reasons`: deterministic reason codes.

## 5. Failure escalation states

When evaluation fails, engines MUST use these outcomes:

1. `block` (fail-closed):
 - Missing or invalid mandatory artifacts on high-risk paths.
 - Unknown profile ID.
 - Composite profile conflict.
 - Class 2-4 profile mismatch.
 - Invalid, expired, or incomplete overrides.
2. `manual_review`:
 - Class 0-1 profile mismatch.
 - Residual risk remains after mandatory checks.
3. `warn`:
 - Class 0-1 non-blocking advisory issues only.
4. `escalate`:
 - Repeated severe violations, unresolved policy conflicts, or emergent hazards.

## 6. Enforcement loop specification

```pseudo
function evaluate_transition(task, desired_state):
 artifact_report = validate_artifacts(task)
 profile_report = resolve_profiles_and_verify(task)

 if profile_report.unknown_profile:
 return block("unknown_profile_id")
 if profile_report.composite_conflict:
 emit_incident_artifact(task)
 return block("composite_profile_conflict")
 if profile_report.override_invalid_or_expired:
 return block("invalid_or_expired_override")
 if profile_report.mismatch and task.risk_class >= 2:
 return block("profile_mismatch_high_impact")
 if profile_report.mismatch and task.risk_class <= 1:
 return manual_review("profile_mismatch_low_impact")

 if artifact_report.missing_or_invalid and is_high_risk_path(task):
 return block("missing_or_invalid_artifacts")
 if artifact_report.missing_or_invalid and task.risk_class <= 1:
 return warn("advisory_artifact_gap")

 runtime_outcome = compute_runtime_outcome(task)
 return runtime_outcome
```

All decisions MUST be logged with profile context for auditability and replay.

## 7. Linking to other sections

1. Enforcement architecture: `runtime/enforcement_and_policy_engine.md`, `runtime/enforcement_architecture_and_implementation.md`
2. Risk/autonomy definitions: `core/risk_classification.md`, `core/agent_autonomy_and_human_oversight.md`
3. Profile framework: `runtime/use_case_profile_framework.md`
4. Artifact matrix: `core/risk_tier_artifact_matrix.md`
5. Telemetry schema: `runtime/telemetry_schema.md`, `runtime/telemetry_example_streams.md`

This runtime specification remains the authoritative runtime gate contract for NAP.


