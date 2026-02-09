# Universal NAP 100 Evaluation Harness

This document codifies a **fail‑closed, deterministic evaluation framework** for assessing compliance of the **NexGentic Agents Protocol (NAP)**. It is derived from the “Ultimate NAP 100‑Score Workflow” and provides guidance for building multi‑agent auditors that enforce objective scoring. The goal is to eliminate subjective judgment and ensure that any evaluation converges on the same score when presented with complete evidence.

## Agent roles and workflow

To achieve robust evaluation, the harness defines distinct auditor roles operating in sequence:

1. **Protocol Analyzer Agent** – Extracts requirements from NAP, builds a compliance checklist and normalises interpretation across models.
2. **Evidence Verifier Agent** – Validates the presence of required evidence artefacts such as risk matrices, trace graphs, enforcement logic, telemetry schema and probabilistic release models.
3. **Enforcement Simulation Agent** – Simulates CI/CD gates, runtime policy blocking, telemetry emission and drift detection to verify enforcement feasibility.
4. **Quantitative Scoring Agent** – Applies a deterministic rubric to compute a score. Opinion‑based scoring is disallowed.
5. **Meta‑Audit Agent** – Audits other agents, detects protocol deviations, scoring bias or hallucinated compliance and ensures adherence to the evaluation procedure.

The agents form a pipeline: **NAP input → Analyzer → Evidence Verifier → Enforcement Simulator → Scorer → Meta‑Audit → Final Score**. Optionally, evaluations can be run across multiple reasoning models and aggregated to remove model bias.

## Evaluation objective

Auditors must determine whether NAP provides complete, enforceable governance across the following domains:

* Lifecycle assurance and audit continuity
* Risk and safety governance (risk class, residual risk, autonomy coupling)
* AI autonomy and governance (behavioural contracts, supply chain security, self‑modification controls)
* Verification and IV&V (testing doctrine, independent verification, red‑team integration)
* Enforcement automation (CI/CD gates, runtime policy enforcement, artefact validation logic)
* Compliance telemetry (event schema, drift detection, health scoring)
* Traceability integrity (trace graph schema, artefact completeness rules)
* Multi‑agent hazard governance (interaction invariants, emergent hazard detection, autonomy containment)
* Probabilistic AI release gating (confidence intervals, variance thresholds, canary rollback triggers)
* Economic and operational risk balancing (cost vs safety rubrics, latency vs risk trade‑offs)

## Scope boundary

This harness produces an **assurance evaluation score** for protocol completeness and enforceability. It is not the same as runtime release authorization. Runtime `approve`/`manual_review`/`block`/`escalate` decisions are computed by the policy engine using `runtime/unified_governance_decision_model.md` and `runtime/compliance_runtime_spec.md`.

## Decision authority boundary (normative)

To avoid duplicate decision paths and "double-divination":

1. This harness is **advisory only** for assurance and audit readiness.
2. Harness outputs **must not** directly authorize or deny runtime transitions or deployments.
3. Final runtime outcomes (`approve`, `manual_review`, `block`, `escalate`) are owned by `runtime/compliance_runtime_spec.md` and `runtime/unified_governance_decision_model.md`.
4. If this harness reports severe gaps, the required action is to open remediation and governance review; runtime authorization still resolves through the runtime policy path.
5. Use canonical decision terminology from `runtime/compliance_runtime_spec.md` to avoid semantic drift.

## Deterministic scoring method

Scoring is not subjective. A 100 % score is awarded only when **all mandatory enforcement evidence exists**, enforcement simulations pass and telemetry schemas are present. Otherwise, scores decrease proportionally to missing evidence. Narrative justification or persuasive language is prohibited. The scoring agent must:

* Validate evidence artefacts exist using the compliance checklist.
* Validate that enforcement pathways (CI/CD gates, runtime guards, drift detectors) are defined and feasible.
* Validate that measurable telemetry schemas exist.
* Simulate typical enforcement scenarios: missing artefacts in pull requests, failing policy checks during deployment, runtime behavioural violations and drift threshold breaches.
* Produce a deterministic final score along with a list of missing artefacts.

### Required evidence checklist

The Evidence Verifier Agent must confirm the presence of the following artefacts:

* **Lifecycle enforcement:** traceability graph schema, artefact completeness rules, lifecycle audit continuity.
* **Risk enforcement:** risk class matrix, residual risk acceptance workflow, autonomy‑risk coupling matrix.
* **AI governance:** runtime behavioural contracts, supply chain security governance, self‑modification controls.
* **Verification:** multi‑layer testing doctrine, independent verification enforcement, red‑team integration.
* **Enforcement automation:** CI/CD policy gate architecture, runtime policy enforcement model, artefact validation logic.
* **Telemetry governance:** compliance event schema, drift detection telemetry, governance health scoring metrics.
* **Probabilistic assurance:** confidence interval release gating, behavioural variance thresholds, canary rollback triggers.
* **Multi‑agent safety:** interaction invariant model, emergent hazard detection rules, cascading autonomy containment logic.
* **Economic governance:** cost vs safety decision rubric, latency and risk trade‑off rules.

### Enforcement simulation requirements

The Enforcement Simulation Agent must demonstrate that the protocol will:

* Block pull requests that omit required artefacts.
* Block deployments that fail policy checks.
* Emit alerts and activate containment when runtime behavioural contracts are violated.
* Trigger escalation when drift telemetry exceeds defined thresholds.

### Executable simulation artifacts

To reduce reliance on conceptual scenarios, run the executable simulation script:

* `tools/run_enforcement_simulations.ps1` writes deterministic scenario results to `audit_outputs/executable_simulation_results.json`.
* `tools/check_policy_runtime_parity.ps1` verifies template/runtime parity and writes `audit_outputs/policy_runtime_parity_report.json`.

These scripts provide machine-checkable evidence for enforcement behavior and reduce interpretation variance across auditors.

## Output format

Auditors must return the following deliverables:

* **Compliance Evidence Matrix** – A table indicating which required artefacts are present and linked in the assurance graph.
* **Enforcement Simulation Results** – Evidence that simulated violations are correctly blocked or escalated.
* **Telemetry Coverage Verification** – Evidence that the telemetry event schema is implemented and covers all required metrics.
* **Deterministic Final Score** – The computed score based solely on evidence presence. If any required evidence is missing, the score is less than 100.
* **Assurance Recommendation** – `assurance_go` or `assurance_no_go` for audit readiness only (non-authorizing).
* **Missing Artefact List** – A list of absent artefacts or incomplete domains.

## How this harness supports self‑auditing

By enforcing a deterministic, evidence‑based evaluation procedure, the harness enables self‑auditing and cross‑model consistency. When NAP implements all required artefacts and automated enforcement pathways, any unbiased evaluator must return a score of 100. Conversely, if evidence is missing, the score will automatically adjust downward. This eliminates subjective judgment and aligns with high‑assurance certification methods.



