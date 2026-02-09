# Risk Tier Artefact Contract Matrix

Auditors require clear, testable mappings between **risk classes**, **autonomy tiers** and the artefacts mandated by the **NexGentic Agents Protocol (NAP)**. This matrix converts narrative governance into a **machine‑validatable contract**. Policy engines use this matrix to determine which artefacts must exist before a task may progress.

Use-case profile note: effective artifact requirements are the union of this matrix and required bundles from selected profiles (`profiles/use_case_profiles.yaml`), with `highest-safety-wins` on conflicts.

## Matrix overview

The matrix below lists artefacts required at **RELEASE** state for each combination of risk class (0–4) and autonomy tier (A0–A4). Intermediate states (PLAN, READ, CHANGE, VERIFY, REVIEW) have similar requirements but with fewer artefacts; see `runtime/compliance_runtime_spec.md` for state‑specific details.

| Risk class \ Autonomy tier | A0 (no autonomy) | A1 (suggest) | A2 (execute reversible) | A3 (execute irreversible) | A4 (self‑modifying) |
|---|---|---|---|---|---|
| **Class 0** | Task header; basic test results | Task header; basic tests | Task header; basic tests; reviewer approval | Task header; basic tests; reviewer approval | Prohibited (upgrade risk class) |
| **Class 1** | + Requirements document | + Requirements; design summary | + Full design doc; traceability matrix | + Design, traceability, risk acceptance form | Prohibited |
| **Class 2** | + Hazard log; architecture review | + Hazard log; architecture review; behavioural contract | + Hazard log; behavioural contract; formal test report; reviewer + IV&V approval | + Hazard log; formal contract; IV&V approval; residual risk acceptance | Prohibited |
| **Class 3** | + Formal design; hazard controls; residual risk acceptance | + Formal design; hazard controls; residual risk acceptance; behavioural contract | + Formal contract; formal proof attachments; IV&V report; risk acceptance with cost/harm analysis | + Formal contract; proof; IV&V; safety board approval; autonomy oversight plan | Allowed only with executive approval, no feasible A3 alternative, signed residual risk acceptance, and continuous runtime monitoring plan |
| **Class 4** | + Independent hazard review; regulator sign‑off | + Independent hazard review; regulator sign‑off; economic & ethical analysis | + Regulator sign‑off; formal contract; proof of safety envelope; external IV&V | + Regulator sign‑off; proof; external IV&V; external ethical review; board approval | Allowed only under exceptional mission constraints with regulator sign‑off, executive authority approval, external IV&V, and continuous kill‑switch telemetry enforcement |

*Legend:*

* **Task header:** Generated from `templates/task_header_template.md`.
* **Requirements document:** See `core/requirements_management.md`.
* **Design summary / full design:** See `core/architecture_design.md`.
* **Hazard log:** Document per `safety/safety_and_assurance.md` and `evaluation/multi_agent_and_emergent_risk.md`.
* **Traceability matrix:** Link artefacts as described in `core/traceability_and_documentation.md`.
* **Behavioural contract:** Defined in `safety/runtime_behavioral_contracts.md`.
* **Formal contract and proof:** See `safety/formal_verification_and_runtime_proof.md`.
* **Test results / formal test report:** See `safety/testing_and_verification.md`.
* **Residual risk acceptance:** See `safety/risk_acceptance_and_residuals.md`.
* **Risk acceptance with cost/harm analysis:** Include decision matrix from `evaluation/economic_and_performance_risk_modeling.md`.
* **Autonomy oversight plan:** Document human oversight roles and kill‑switch patterns (`core/agent_autonomy_and_human_oversight.md`).
* **Regulator sign‑off:** External audit or certification for highest risk levels.

## Usage in policy engines

Policy engines load this matrix and evaluate tasks by locating the row (risk class) and column (autonomy tier) that match the task. The engine unions matrix-required artifacts with profile-required bundle controls before evaluating compliance. It then asserts that all listed artifacts exist, are complete, signed and traced. If any artifact is missing or invalid, the task is blocked until remediation. Autonomy tier A4 is prohibited for Class 0-2 tasks and treated as exceptional for Class 3-4 tasks, where explicit approvals and enhanced controls are mandatory.

## Linking to other sections

* **Risk classification:** The definitions of risk classes and autonomy tiers are in `core/risk_classification.md` and `core/agent_autonomy_and_human_oversight.md`. Use this matrix to enforce the tailoring rules.
* **Compliance runtime:** State‑specific artefact requirements are detailed in `runtime/compliance_runtime_spec.md`.
* **Policy engine:** Implementation details for loading and enforcing the matrix are in `runtime/enforcement_and_policy_engine.md` and `runtime/enforcement_architecture_and_implementation.md`.
* **Economic and ethics:** For high risk classes (3–4), include economic and societal impact documentation (`evaluation/economic_and_performance_risk_modeling.md`).

The risk tier artefact contract matrix makes compliance **explicit**. It allows auditors and automated tools to verify that appropriate artefacts are present for a given risk and autonomy combination, closing the gap between narrative policy and executable enforcement.



