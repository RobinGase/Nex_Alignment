# Governance Parameter Registry and Normative Boundaries

The **NexGentic Agents Protocol (NAP)** defines numerous numerical thresholds, weights and timing constants to guide classification, assurance, gating and escalation. To avoid divergence across documents and to make auditing easier, NAP consolidates these constants into a single **parameter registry**. This document also clarifies which parameters are **normative** (mandatory for certification and compliance) and which are **reference** (recommended defaults that organisations MAY customise with justification).

## 1. Purpose

1. **Consistency.** By defining parameters in one location, all documents can reference the same symbols rather than duplicating values. This prevents subtle discrepancies that undermine compliance automation.
2. **Transparency.** Auditors and governance boards can review parameter definitions and changes in a single place. Parameter changes must be versioned and justified, similar to code changes.
3. **Normative clarity.** Parameters marked **normative** are required by the protocol; changes to these values must be approved by the governance board and may impact certification. Parameters marked **reference** provide suggested values but may be tuned by organisations based on domain risk appetite, provided the rationale is documented in the trace graph and risk register.

## 2. Parameter table

| Parameter ID | Description | Default Value | Normative? | Used in |
|---|---|---|---|---|
| **FIN_TXN_T2** | Financial transaction threshold for elevating tasks to at least Class 2. Represents the transaction amount at which financial impact becomes significant. | organisation‑defined (example: \$10,000) | Reference | `core/risk_classification.md`, `evaluation/economic_and_performance_risk_modeling.md` |
| **USER_BLAST_RADIUS_T1** | Maximum number of users affected before raising the risk class. Used to determine blast radius for reliability and error budget. | organisation‑defined (example: 1,000 users) | Reference | `core/risk_classification.md` |
| **BASELINE_SCORE_CLASS_0…4** | Baseline scores used in the unified decision model for each risk class. Default mapping: Class 0 = 100, Class 1 = 95, Class 2 = 90, Class 3 = 80, Class 4 = 70. | See description | Normative | `runtime/unified_governance_decision_model.md` |
| **AUTONOMY_ADJ_A0…A4** | Score adjustments by autonomy tier: A0 = 0, A1 = −2, A2 = −5, A3 = −10, A4 = −15. A4 is prohibited for Class 0–2 tasks and only permitted for Class 3–4 tasks with explicit authority approval and residual risk acceptance. | See description | Normative | `runtime/unified_governance_decision_model.md`, `core/risk_tier_artifact_matrix.md` |
| **T_APP**, **T_REVIEW**, **T_BLOCK** | Threshold bands for governance decisions. Defaults: T_APP = 90, T_REVIEW = 80–89, T_BLOCK = <80. | See description | Normative | `runtime/unified_governance_decision_model.md` |
| **PSI_WARN**, **PSI_CRIT** | Population stability index thresholds: 0.25 (warning), 0.5 (critical). PSI below 0.1 requires no action. | 0.25 (warning), 0.5 (critical) | Reference | `evaluation/probabilistic_assurance_and_release_metrics.md`, `runtime/compliance_scoring_and_metrics.md` |
| **KS_WARN**, **KS_CRIT** | Kolmogorov–Smirnov statistic thresholds: 0.1 (warning), 0.2 (critical). | 0.1 (warning), 0.2 (critical) | Reference | `evaluation/probabilistic_assurance_and_release_metrics.md`, `runtime/compliance_scoring_and_metrics.md` |
| **RELIABILITY_THRESHOLD** | Minimum acceptable reliability index. Default: 0.9. Below this value, tasks cannot be auto‑approved. | 0.9 | Normative | `evaluation/probabilistic_assurance_and_release_metrics.md`, `runtime/unified_governance_decision_model.md` |
| **MAX_WIDTH_DEFAULT** | Maximum acceptable 95 % confidence interval width for the key safety metric. Used to normalise interval width. | 0.05 | Reference | `evaluation/probabilistic_assurance_and_release_metrics.md` |
| **ESCALATION_TIMEOUT_CLASS_2**, **ESCALATION_TIMEOUT_CLASS_3**, **ESCALATION_TIMEOUT_CLASS_4** | Maximum allowed time to resolve escalations by risk class. Defaults: Class 2 = 48 h, Class 3 = 24 h, Class 4 = 12 h. After these windows, fallback decisions apply. | See description | Normative | `runtime/enforcement_and_policy_engine.md` |
| **DRIFT_METRIC_DEFAULT** | Default drift metric for reliability calculations. Default: population stability index (PSI). Organisations MAY use alternatives (e.g., KL divergence) but must justify the choice and define thresholds. | PSI | Normative | `evaluation/probabilistic_assurance_and_release_metrics.md` |
| **WEIGHTS_W1, W2, W3** | Default weights for reliability index components: error rate (w1), drift metric (w2), confidence interval width (w3). Must sum to 1. Default: w1 = 0.5, w2 = 0.3, w3 = 0.2. | 0.5, 0.3, 0.2 | Reference | `evaluation/probabilistic_assurance_and_release_metrics.md`, `runtime/unified_governance_decision_model.md` |
| **COMPLIANCE_SCORE_THRESHOLD** | Minimum acceptable compliance score before the unified governance decision model triggers a review or blocks deployment. Scores below this value require remediation and may prevent automated approval. Default: 90. | 90 | Normative | `runtime/compliance_scoring_and_metrics.md`, `runtime/unified_governance_decision_model.md` |

The table above lists common parameters. Organisations MAY define additional parameters (e.g., custom metrics for domain‑specific hazards) and add them to this registry. When extending or overriding reference parameters, provide a rationale in the parameter file and update cross‑references in other documents.

## 3. Normative vs reference guidance

1. **Normative parameters** MUST be adhered to exactly unless the governance board approves a deviation. Deviations must be documented in the trace graph and risk register and may affect certification. Examples: baseline scores, autonomy adjustments, approval thresholds, escalation timeouts.
2. **Reference parameters** are suggested defaults. Organisations MAY adjust these values to reflect domain risk appetite, data distributions or business context. Adjustments MUST be recorded in this registry along with justification and must not conflict with safety or regulatory requirements. Examples: PSI and KS thresholds, maximum confidence interval width, reliability weights, financial transaction thresholds.
3. **Immutable parameters** represent policies that cannot be overridden without revising the protocol itself (e.g., A4 is prohibited for Class 0–2 and only allowed for Class 3–4 under exceptional controls). These are implicitly normative.

## 4. Parameter synchronization and governance

1. **Single source of truth.** All documents must refer to parameters via their IDs. Do not embed numeric values in other documents; instead write “see `core/governance_parameter_registry.md`” or use the parameter ID. This allows automation to substitute values and verify consistency.
2. **Change control.** Parameter changes follow the same change control process as policy definitions: propose a modification, record the rationale and impact analysis, obtain approvals, update this registry and increment the registry version.
3. **Auditability.** Parameter changes should be anchored via digital signatures (`safety/evidence_anchor_and_log_integrity.md`). Tools reading the parameter registry must verify signatures and confirm that no tampering has occurred.
4. **Default values.** The default values provided in this document are based on industry practices and NIST guidance; they should serve most organisations. Higher‑risk domains (e.g., aerospace, medical) may adopt stricter values.

By centralising parameters and clarifying their normative status, NAP ensures that governance decisions are consistent, auditable and adaptable. Auditors can review this registry to verify that organisations have not silently changed safety‑critical thresholds. Developers and policy engines can reference parameter IDs to avoid duplication and reduce errors.



