# Compliance Scoring and Metrics

Governance is only meaningful when its effectiveness can be measured. This document defines a **compliance scoring framework** for the **NexGentic Agents Protocol (NAP)**. It introduces quantitative metrics, scoring formulas and drift thresholds that drive the policy engine and dashboards. By operationalising metrics, organisations can assess governance health and detect anomalies in real time.

## Scope and authority boundary

The compliance score is a **governance health metric** and a quantitative input to the unified runtime decision model. It is not a separate deployment authorization path.

1. Runtime authorization outcomes (`approve`, `manual_review`, `block`, `escalate`) remain owned by `runtime/compliance_runtime_spec.md` and `runtime/unified_governance_decision_model.md`.
2. Compliance score thresholds trigger review/escalation workflows, not independent final release decisions, except when explicit fail-closed conditions occur.
3. Fail-closed conditions must be routed through the runtime authorization path so that outcomes remain deterministic and auditable.

## Event classification model

All telemetry events (`runtime/telemetry_schema.md`) belong to one of the following categories:

1. **Governance events** – Represent actions taken by the policy engine or governance agents. Examples: `policy_violation`, `approval_required`, `approval_granted`, `risk_acceptance_expiry`, `policy_update`.
2. **Runtime events** – Emitted by guardian agents or runtime monitors. Examples: `runtime_violation`, `contract_enforced`, `resource_limit_exceeded`.
3. **Drift and variance events** – Emitted by drift detectors. Examples: `variance_threshold_exceeded`, `drift_detected`.
4. **Security events** – Generated when a security issue is detected. Examples: `security_alert`, `signature_mismatch`.
5. **Health events** – Periodic status reports. Examples: `telemetry_health`, `policy_engine_health`, `compliance_score`.
6. **Economic events** – Events linking safety and economic metrics. Examples: `cost_overrun`, `latency_violation`, `performance_degradation`.

Event classification helps dashboards filter and aggregate metrics by category.

## Quantitative drift threshold definitions

Drift detection uses statistical tests to compare current data or behaviour distributions against reference distributions. Common metrics include **population stability index (PSI)** and **Kolmogorov–Smirnov (K‑S) statistic**. NIST notes that AI systems must monitor distribution differences and trigger alerts when thresholds are exceeded. For large language models and multi‑agent systems, drift may also manifest in behaviour rather than raw feature distributions. Teams SHOULD therefore monitor **prompt suite coverage**, **rubric alignment drift** and **tool‑call profile drift**—for example, tracking the frequency and diversity of tool calls or the distribution of prompt categories compared with historical baselines. The thresholds for PSI and K‑S are defined by the **`PSI_WARN`, `PSI_CRIT`, `KS_WARN`** and **`KS_CRIT`** parameters in the `core/governance_parameter_registry.md`. Organisations MUST use these parameter IDs when configuring drift detectors and adjust values via the registry if necessary. Recommended thresholds:

| Metric | Threshold | Action |
|---|---|---|
| **PSI** | <`PSI_WARN` | Monitor only (low drift). |
| **PSI** | [`PSI_WARN`, `PSI_CRIT`] | Warning; schedule retraining or review. |
| **PSI** | >`PSI_CRIT` | Critical drift; block deployment and trigger rollback. |
| **K‑S statistic** | <`KS_WARN` | Normal variation. |
| **K‑S statistic** | [`KS_WARN`, `KS_CRIT`] | Warning. |
| **K‑S statistic** | >`KS_CRIT` | Critical drift; stop and investigate. |

Organisations should tune thresholds based on domain risk appetite. The policy engine uses these thresholds to generate `variance_threshold_exceeded` events and enforce rollback.

## Compliance scoring formula

The compliance score summarises governance health over a defined period (e.g., a sprint or release). It ranges from 0 to 100 and is computed as follows:

1. **Base score (100 points).** Start from 100.
2. **Evidence completeness penalty.** For each missing artefact or incomplete trace link detected, subtract 2 points.
3. **Policy violation penalty.** For each `policy_violation` event recorded, subtract 1 point. Critical violations (e.g., release gating failures) subtract 3 points.
4. **Drift incident penalty.** For each critical drift or variance event, subtract 2 points.
5. **Runtime violation penalty.** For each `runtime_violation` event, subtract 2 points. For each emergent behaviour incident requiring containment, subtract 3 points.
6. **Economic overrun penalty.** For each `cost_overrun` or `latency_violation` event, subtract 1 point.
7. **Residual risk renewal penalty.** If residual risk acceptance forms expire without renewal, subtract 1 point per incident.
8. **Bonus.** Add 5 points if no critical violations occurred and all artefacts were complete for the period.

**Fail‑closed conditions:** Certain violations MUST override the numeric compliance score. These include cryptographic signature mismatches, proof or contract hash mismatches, runtime invariant breaches, unsafe tool execution attempts, and unmitigated critical hazards. If any fail‑closed condition occurs, the policy engine MUST set the effective compliance score to 0 and route the decision through the runtime authorization path (`runtime/compliance_runtime_spec.md`, `runtime/unified_governance_decision_model.md`) with an effective `block` or `escalate` outcome. This ensures that safety cannot be outweighed by positive scores in other categories.

**Example:** In a sprint, the organisation had 1 missing artefact (−2), 2 minor policy violations (−2), 1 runtime violation (−2) and 1 cost overrun (−1). No critical incidents. The compliance score = 100 − 2 − 2 − 2 − 1 + 5 = 98.

Scores below the **`COMPLIANCE_SCORE_THRESHOLD`** parameter trigger governance review and remediation. They MUST NOT be treated as a standalone release gate outside the runtime authorization model unless a fail-closed condition is present. Publish compliance scores via `telemetry_health` events to monitoring dashboards. Thresholds MUST be updated via the parameter registry and referenced by ID.

### Integration with the unified decision model

The **compliance score** feeds directly into the unified governance decision model (`runtime/unified_governance_decision_model.md`). In that model, the compliance penalty `Cp` is defined as half the complement of the compliance score (i.e., `Cp = (100 – ComplianceScore)/2`). A high compliance score therefore reduces or eliminates the penalty, whereas a low score contributes significantly to the overall governance score reduction. Integrating compliance scoring into a single decision pipeline reduces duplication and ensures that policy engines treat compliance health as a first-class quantitative input.

## Linking to other sections

* **Telemetry schema:** Event categories and metrics align with the fields defined in `runtime/telemetry_schema.md` and the examples in `runtime/telemetry_example_streams.md`.
* **Probabilistic assurance:** Drift thresholds integrate with probabilistic release gating in `evaluation/probabilistic_assurance_and_release_metrics.md`.
* **Economic risk modelling:** Economic events and penalties align with the trade‑off analysis in `evaluation/economic_and_performance_risk_modeling.md`.
* **Compliance telemetry:** The metrics and scoring contribute to governance health scoring and drift detection (`runtime/compliance_telemetry_and_governance_drift.md`).

By defining event categories, thresholds and scoring formulas, NAP turns compliance monitoring into an **operational instrument** rather than a narrative description. Scores provide immediate feedback and enable quantitative governance decisions.



