# Use-Case Profile Framework

This document defines the modular Use-Case Profile Layer for the NexGentic Agents Protocol (NAP). It allows agents to select governance controls by domain (for example, website work, database operations, payments, or AI stack changes) while preserving deterministic fail-closed enforcement.

## 1. Scope and intent

Profiles augment existing NAP risk and autonomy controls. They do not replace:

- `core/risk_classification.md`
- `core/agent_autonomy_and_human_oversight.md`
- `runtime/compliance_runtime_spec.md`
- `runtime/unified_governance_decision_model.md`

## 2. Normative profile declaration rules

1. Each task MUST declare one `primary_use_case_profile`.
2. Each task MAY declare up to two `secondary_use_case_profiles`.
3. Total selected profiles MUST NOT exceed three.
4. Profile declaration is mandatory for Class 2-4 tasks.
5. Profile declaration is strongly recommended for Class 0-1 tasks.

If profile declaration is missing:

- Class 2-4 tasks: `block`
- Class 0-1 tasks: `manual_review`

## 3. Catalog and bundle sources

- Bundle catalog: `profiles/use_case_bundles.yaml`
- Profile catalog: `profiles/use_case_profiles.yaml`

Each profile references one or more reusable alignment bundles. Bundles anchor to existing NAP controls and documents.

## 4. Deterministic composite policy

For one primary profile plus zero to two secondary profiles:

1. Effective profile set = unique union of declared profiles.
2. Effective bundle set = union of all required bundles from effective profiles.
3. Effective minimum risk class = max of profile minimum risk classes.
4. Effective autonomy ceiling = most restrictive profile ceiling (lowest tier).
5. Conflict resolution = `highest-safety-wins`.

## 5. Runtime verification requirements

Policy engines MUST verify:

1. Profile IDs exist in `profiles/use_case_profiles.yaml`.
2. Operation tags are compatible with the selected profile set.
3. Declared risk class meets effective minimum risk class.
4. Declared autonomy tier does not exceed effective autonomy ceiling.
5. Override IDs (if any) are valid, active, and in-policy.

Decision handling:

- Unknown profile ID: `block`
- Composite profile conflict: `block` and emit incident artifact
- Profile mismatch for Class 2-4: `block`
- Profile mismatch for Class 0-1: `manual_review`

## 6. Overrides and waiver boundaries

Profile overrides are tightly constrained:

1. Overrides MAY apply only to reference-level controls.
2. Immutable and normative constraints remain non-waivable.
3. Every override MUST include:
 - rationale
 - compensating controls
 - approver
 - expiry
4. Expired or incomplete overrides MUST produce `block`.

Use `templates/use_case_override_request_template.md` to submit overrides.

## 7. Authority boundary (anti double-divination)

To avoid duplicate gate authority:

1. Runtime ownership remains with `runtime/compliance_runtime_spec.md` and `runtime/unified_governance_decision_model.md`.
2. Profile layer provides deterministic inputs to runtime enforcement.
3. Audit harness outputs remain advisory (`assurance_go` / `assurance_no_go`) and are not runtime authorization decisions.

## 8. Recommended operation tags

Implementations should classify actions with domain tags such as:

- `ui_content`, `frontend`, `database_schema`, `data_migration`
- `currency_transfer`, `settlement`, `fraud_control`
- `model_training`, `model_inference`, `etl`, `deployment`
- `incident_triage`, `identity_verification`, `third_party_api`

Tag vocabularies MAY be extended, but extensions should be versioned and documented.

## 9. Versioning and change control

1. Profile and bundle files MUST include explicit version fields.
2. Additive profile updates should be backward compatible where possible.
3. Breaking changes MUST include migration notes and updated simulation coverage.
4. Change control should follow `core/normative_and_reference_guidance.md`.

## 10. Minimal verification pseudocode

```text
resolve_profiles(primary, secondary[]):
 assert primary exists
 assert len(secondary) <= 2
 effective_profiles = unique(primary + secondary)
 assert no composite conflict

 effective_bundles = union(required_bundles(profile) for profile in effective_profiles)
 min_risk_floor = max(min_risk_class(profile) for profile in effective_profiles)
 autonomy_ceiling = min(autonomy_ceiling(profile) for profile in effective_profiles)

 return effective_profiles, effective_bundles, min_risk_floor, autonomy_ceiling
```

This profile framework keeps NAP modular across domains while preserving deterministic enforcement for high-impact operations.


