# Unified Governance Decision Model

Complex governance processes can become fragmented when **risk classification**, **compliance scoring**, **probabilistic release gates** and **residual risk acceptance** are treated as independent activities. Reviewers of NAP noted that sections on compliance scoring, probabilistic assurance, risk modelling and enforcement sometimes appeared as parallel systems rather than layers of a single decision model. This document unifies those concepts into a **single governance decision pipeline**. The goal is to provide a machine‑executable framework that determines whether a task or model update may proceed, requires manual intervention or must be blocked.

## Overview

At its core, NAP’s decision engine assigns each task a **base governance score** derived from its **risk class (0–4)** and **autonomy tier (A0–A4)**. High risk classes and autonomy tiers start with a lower base score, reflecting their greater inherent risk. The engine then applies a series of **penalties** based on compliance health, drift and reliability metrics, economic harm potential and residual risk status. The resulting score is compared to decision thresholds to determine the outcome:

* **Approve:** Score ≥ threshold. The task or release is automatically approved.
* **Manual review (`manual_review`):** Score within a near-threshold band. A human reviewer decides whether to proceed.
* **Block:** Score < threshold. The pipeline fails closed until deficiencies are addressed.
* **Escalate:** Safety-critical vetoes, unresolved policy conflicts or repeated severe violations force governance-board escalation.

## Scope boundary

This model is the **runtime governance decision function** used by policy engines for task and release gating. It is distinct from the evaluation harness scores in `evaluation/nap_evaluation_harness.md` and `evaluation/multi_lens_evaluation_harness.md`, which are **assurance audit scores** used to evaluate protocol completeness and implementation maturity. Evaluation harness scores do not directly authorize deployments.

Canonical decision terminology and precedence ownership are defined in `runtime/compliance_runtime_spec.md` (Section "Decision authority, precedence and terminology"). Implementations should use those canonical terms to avoid semantic drift across documents.

### Input precedence and conflict resolution

Governance decisions may involve conflicting signals—for example, a task may achieve high procedural compliance but have low reliability metrics. To avoid ambiguity and ensure safety, NAP adopts a **fail‑closed precedence model**:

1. **Safety signals dominate.** If any safety‑critical check fails (e.g., the task exceeds allowed risk class/autonomy tier, a hazard control is missing, a residual risk has expired or there is an unresolved catastrophic hazard), the decision immediately defaults to **Block** or **Escalate** regardless of other scores. Safety failures cannot be offset by strong performance in other areas.
2. **Reliability overrides compliance.** If the **ReliabilityIndex** falls below its minimum threshold, the outcome can be no higher than **Manual review** (and may escalate to **Block** under hard-veto conditions). High compliance scores cannot mask poor probabilistic assurance.
3. **Economic and performance factors modulate but do not override safety and reliability.** Economic penalties and operational considerations are applied only after safety and reliability conditions are satisfied. They adjust the final score but never elevate a decision when safety or reliability is deficient.
4. **Residual risk is time‑bounded.** Residual risk acceptances include expiry dates (see `safety/risk_acceptance_and_residuals.md`). When a residual risk expires without reevaluation, the system applies additional penalties and treats the residual hazard as unresolved until a new acceptance is recorded.

These precedence rules ensure that the most severe risk dimensions always control the final decision, preventing optimisation of one metric at the expense of hidden hazards.

The unified decision pipeline is:
`risk_class + autonomy_tier -> base score -> subtract (Cp + Pp + Ep + Rp) -> apply precedence vetoes -> approve/manual_review/block/escalate`.

## Base governance score

1. **Risk class baseline.** Assign a baseline score for each risk class (0–4). Use the constants `BASELINE_SCORE_CLASS_0…4` defined in the parameter registry (`core/governance_parameter_registry.md`). Higher classes start with a lower score because they carry more inherent risk.
2. **Autonomy tier adjustment.** Reduce the baseline score based on autonomy tier. Use the constants `AUTONOMY_ADJ_A0…A4` from the parameter registry. A4 is prohibited for Class 0–2 and allowed only for Class 3–4 under exceptional controls per `core/risk_tier_artifact_matrix.md`.

The **base governance score** is then:

\[
\text{BaseScore} = \text{Baseline(RiskClass)} + \text{Adjustment(AutonomyTier)}
\]

## Penalty components

The policy engine subtracts penalties for observed deviations. These components are defined in other NAP documents but are summarised here to illustrate how they combine:

1. **Compliance penalty (Cp).** Derived from the **compliance score** in `runtime/compliance_scoring_and_metrics.md`. Compute `Cp = (100 – ComplianceScore)/2`. A perfect compliance score (100) yields no penalty; a score of 80 yields a 10‑point penalty.
2. **Probabilistic penalty (Pp).** Derived from reliability metrics in `evaluation/probabilistic_assurance_and_release_metrics.md`. Compute `Pp = 100 × \max\{0, \text{Threshold} – \text{ReliabilityIndex}\}` where **ReliabilityIndex** is a normalised measure (0–1) combining confidence interval widths, variance and drift metrics. See the next section for its definition.
3. **Economic & harm penalty (Ep).** Derived from the **decision matrix** in `evaluation/economic_and_performance_risk_modeling.md`. Tasks with high potential cost or harm incur higher penalties. For example, if the cost of failure is high (>$1 M) and user harm potential is catastrophic, subtract 10 points; if both are low, subtract nothing.
4. **Residual risk penalty (Rp).** If a task has unresolved or expired residual risk acceptance (`safety/risk_acceptance_and_residuals.md`), subtract a penalty proportional to the severity of the unresolved hazards (e.g., 5 points per unresolved critical hazard).

 **Reevaluation schedule.** Residual risk acceptances must specify an expiry date and a reevaluation interval. Upon expiry, the residual risk is automatically considered unresolved and `Rp` increases by a fixed amount for each evaluation cycle that elapses without renewal (e.g., +2 points per cycle). The policy engine must trigger a review when residual risks approach expiry and update the risk register accordingly. This prevents indefinite reliance on outdated acceptances and enforces continuous risk management.

The **governance score** is then:

\[
\text{GovernanceScore} = \text{BaseScore} – (C_p + P_p + E_p + R_p)
\]

## Reliability index

The **ReliabilityIndex** summarises probabilistic assurance metrics into a single value in \[0, 1\]. A value of 1 indicates perfect reliability; 0 indicates unacceptable risk. Compute it as a weighted average of normalised metrics:

\[
\text{ReliabilityIndex} = w_1 \times (1 - \text{ErrorRate}) + w_2 \times (1 - \text{DriftMetric}) + w_3 \times \left(1 - \frac{\text{ConfidenceIntervalWidth}}{\text{MaxWidth}}\right)
\]

Where:

* **ErrorRate** = observed error rate (0–1) on validation or canary sets.
* **DriftMetric** = normalised drift measure (e.g., population stability index scaled to \[0, 1\]).
* **ConfidenceIntervalWidth** = width of the 95 % confidence interval for the key safety metric, normalised by `MaxWidth` (maximum acceptable width).
* `w_1 + w_2 + w_3 = 1` are weights reflecting organisational priorities (e.g., `w_1 = 0.5`, `w_2 = 0.3`, `w_3 = 0.2`).

Organisations adjust weights and thresholds based on risk appetite. The `evaluation/probabilistic_release_gate_example.md` shows how these metrics are computed.

### Statistical rigour

Reliability metrics must be based on **statistically valid samples** and calibrated models. At a minimum:

* **Data sufficiency.** Evaluation datasets and canary sets must be large enough to estimate error rates and confidence intervals with acceptable precision (e.g., confidence interval widths less than the `MaxWidth` parameter). If the evaluation sample is too small or unrepresentative, the reliability index cannot be computed and the release is automatically blocked.
* **Model calibration.** Confidence intervals should be derived from calibrated models. Use techniques such as reliability diagrams or expected calibration error (ECE) to verify calibration. Poorly calibrated models should either be recalibrated or yield lower reliability scores.
* **Drift justification.** Drift metrics (e.g., population stability index, Kullback–Leibler divergence) must be justified for the domain and accompanied by thresholds approved by the governance board. Document the choice of statistic and rationale in the test report.

These requirements ensure that probabilistic assurance is evidence‑based and reproducible rather than subjective.

## Decision thresholds

Define threshold bands for the final governance score. The decision engine produces a **single outcome** (`approve`, `manual_review`, `block` or `escalate`). Outcomes are **mutually exclusive**-a task cannot be both restricted and escalated, for example. If multiple conditions are met (e.g., a low score and a rule requiring escalation), the **most conservative outcome** is selected (`escalate` > `block` > `manual_review` > `approve`). This simplifies downstream processing and avoids conflicting instructions.

* **Approval threshold (T_app)**: Defined by the parameter `T_APP` in `core/governance_parameter_registry.md`. Scores equal to or above this threshold result in automatic approval.
* **Manual review band (T_review)**: Defined by `T_REVIEW`. Scores within this band require human review. The reviewer may override or accept based on context.
* **Block threshold (T_block)**: Defined by `T_BLOCK`. Scores below this threshold automatically block the task until remedial actions are taken.

Thresholds should be tuned over time based on historical incident data and domain‑specific risk tolerance. Store threshold configuration in the policy engine (`runtime/enforcement_and_policy_engine.md`), update values in the parameter registry and record changes in the assurance graph.

## Worked example

Consider a task with `Class 2` and `Autonomy A2` and with the following metrics:

* Compliance score: 92
* Error rate: 1.5 % with 95 % confidence interval width 0.02
* Drift metric (PSI): 0.15
* Cost of failure: Medium
* User harm: Minor
* No unresolved residual hazards

Base score = 90 (Class 2 baseline) – 5 (A2 adjustment) = 85. Here, 90 is the default `BASELINE_SCORE_CLASS_2` and 5 is the absolute value of `AUTONOMY_ADJ_A2` in the parameter registry. Projects MUST compute base scores using these parameter values to ensure consistency.

* Compliance penalty: (100 – 92)/2 = 4.
* Reliability index: `RI = 0.5 × (1 – 0.015) + 0.3 × (1 – 0.15) + 0.2 × (1 – (0.02/0.05)) ≈ 0.5×0.985 + 0.3×0.85 + 0.2×0.6 ≈ 0.493 + 0.255 + 0.12 = 0.868`. Penalty `Pp = 100 × max(0, **RELIABILITY_THRESHOLD** – 0.868)`. Using the default `RELIABILITY_THRESHOLD` value of 0.9 yields a penalty of 3.2 points.
* Economic penalty: medium cost and minor harm yield a 2‑point penalty (from the decision matrix in `evaluation/economic_and_performance_risk_modeling.md`).
* Residual risk penalty: 0.

Governance score = 85 – (4 + 3.2 + 2 + 0) ≈ 75.8. This is below the block threshold, so the policy engine will **block** the release and request mitigation (e.g., improve compliance or reduce drift).

## Linking to other sections

* **Risk classification:** Baseline scores and autonomy adjustments derive from `core/risk_classification.md` and `core/agent_autonomy_and_human_oversight.md`.
* **Compliance scoring:** Use `runtime/compliance_scoring_and_metrics.md` to compute the compliance penalty and integrate it here.
* **Probabilistic assurance:** Use `evaluation/probabilistic_assurance_and_release_metrics.md` and `evaluation/probabilistic_release_gate_example.md` to compute the reliability index and probabilistic penalty.
* **Economic modelling:** Use the deterministic decision matrix in `evaluation/economic_and_performance_risk_modeling.md` to compute economic penalties.
* **Risk acceptance:** Use `safety/risk_acceptance_and_residuals.md` to account for unresolved residual hazards.
* **Policy engine:** Integrate this unified decision model into the policy evaluation workflow (`runtime/enforcement_and_policy_engine.md` and `runtime/compliance_runtime_spec.md`). Store the final governance score and thresholds in the assurance graph for auditability.

By unifying scoring, gating and risk acceptance into a single decision model, NAP eliminates duplicated logic and provides a **transparent, quantitative basis** for release decisions. This model can be implemented by policy engines, audited by safety boards and tuned over time based on empirical data.



